//
//  ZZGridPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZGridDataSource.h"
#import "ZZVideoRecorder.h"
#import "ZZVideoUtils.h"
#import "ZZSoundPlayer.h"
#import "ZZVideoPlayer.h"
#import "TBMFriend.h"
#import "iToast.h"
#import "ZZContactDomainModel.h"
#import "TBMPhoneUtils.h"
#import "ZZAPIRoutes.h"
#import "ZZGridAlertBuilder.h"
#import "ZZUserDataProvider.h"
#import "TBMEventsFlowModuleInterface.h"
#import "TBMEventsFlowModulePresenter.h"
#import "TBMAlertController.h"
#import "TBMAppDelegate.h"
#import "ZZFeatureObserver.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridActionHandler.h"
#import "TBMTableModal.h"
#import "ZZCoreTelephonyConstants.h"
#import "ZZGridPresenter+UserDialogs.h"


@interface ZZGridPresenter ()
<
ZZGridDataSourceDelegate,
ZZVideoPlayerDelegate,
ZZVideoRecorderDelegate,
ZZGridActionHanlderDelegate,
TBMTableModalDelegate
>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZSoundPlayer* soundPlayer;
@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;
@property (nonatomic, strong) ZZGridActionHandler* actionHandler;
@property (nonatomic, strong) ZZContactDomainModel* contactWithMultiplyPhones;
@property (nonatomic, strong) TBMFriend* notificationFriend;
@property (nonatomic, strong) TBMFriend* notifatedFriend;
@property (nonatomic, assign) BOOL isVideoRecorderActive;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController <ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
//    self.actionHandler = [ZZGridActionHandler new];
    self.actionHandler.delegate = self;
    self.actionHandler.userInterface = self.userInterface;
    
    self.dataSource = [ZZGridDataSource new];
    self.dataSource.delegate = self;
    [self.userInterface updateWithDataSource:self.dataSource];
    
    self.videoPlayer = [ZZVideoPlayer new];
    self.videoPlayer.delegate = self;
    [self _setupNotifications];
    [self.interactor loadData];
    
    [[RACObserve(self.videoPlayer, isPlayingVideo) filter:^BOOL(id value) {
        return [value integerValue] == 0;
    }] subscribeNext:^(id x) {
        [self updateFriendIfNeeded];
    }];
    
    
    [[ZZVideoRecorder shared] addDelegate:self];
}

- (void)_setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGridData:)
                                                 name:kFriendChangeNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_videoWasViewed:)
                                                 name:kFriendVideoViewedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendMessageEvent)
                                                 name:kNotificationSendMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateFeatures)
                                                 name:kFeatureObserverFeatureUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlaying)
                                                 name:kNotificationIncomingCall
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoStartDownloadingNotification:)
                                                 name:kVideoStartDownloadingNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZZVideoRecorder shared] removeDelegate:self];
}

- (void)sendMessageEvent
{
    [self.actionHandler handleEvent:ZZGridActionEventTypeOutgoingMessageDidSend];
    [self.dataSource reloadStorage];
}

- (void)_videoWasViewed:(NSNotification*)notif
{
    [self.actionHandler handleEvent:ZZGridActionEventTypeOutgoingMessageWasViewed];
    [self updateGridData:notif];
}


#pragma mark - Notifications

- (void)videoStartDownloadingNotification:(NSNotification*)notification
{
    ANDispatchBlockToMainQueue(^{
        if (!self.videoPlayer.isPlayingVideo)
        {
            [self.interactor showDownloadAniamtionForFriend:notification.object];
        }
        else
        {
            self.notificationFriend = notification.object;
        }
        [self.dataSource reloadStorage];
    });
}

- (void)reloadGridWithData:(NSArray*)data
{
    if (!self.isVideoRecorderActive)
    {
        [self.dataSource setupWithModels:data];
    }
}

- (void)updateGridData:(NSNotification*)notification
{
    if (!self.videoPlayer.isPlayingVideo)
    {
        if (self.notificationFriend)
        {
            self.notificationFriend = notification.object;
            [self updateFriendIfNeeded];
        }
        else
            
        {
            [self.interactor handleNotificationForFriend:notification.object];
        }
    }
    else
    {
        self.notificationFriend = notification.object;
    }
    
    [self.dataSource reloadStorage];
}

- (void)updateGridWithModelFromNotification:(ZZGridDomainModel *)model isNewFriend:(BOOL)isNewFriend
{
    [self.dataSource updateDataSourceWithGridModelFromNotification:model
                                               withCompletionBlock:^(BOOL isNewVideoDownloaded) {
                                                   if (isNewVideoDownloaded)
                                                   {
                                                       if (model.relatedUser.outgoingVideoStatusValue != OUTGOING_VIDEO_STATUS_VIEWED)
                                                       {
                                                           [self.soundPlayer play];
                                                       }
                                                   }
                                               }];
    
    if (isNewFriend)
    {
        [self.userInterface showFriendAnimationWithModel:model.relatedUser];
        [self.actionHandler handleEvent:ZZGridActionEventTypeFriendDidAdd];
    }
}

- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model
{
    [self.actionHandler handleEvent:ZZGridActionEventTypeIncomingMessageDidReceived]; // TODO:
    [self.dataSource updateDataSourceWithDownloadAnimationWithGridModel:model
                                                    withCompletionBlock:^(BOOL isNewVideoDownloaded) {}];
}

//- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel*)model
//{
//    if (!ANIsEmpty(model.relatedUser))
//    {
//        [self.interactor updateLastActionForFriend:model.relatedUser];
//    }
//    [self.dataSource selectedViewModelUpdatedWithItem:model];
//}


//- (void)updateGridWithGridDomainModel:(ZZGridDomainModel *)model
//{
//    if (!ANIsEmpty(model.relatedUser))
//    {
//        [self.interactor updateLastActionForFriend:model.relatedUser];
//    }
//    [self.dataSource updateModel:model];
//}

- (void)updateGridWithModel:(ZZGridDomainModel*)model
{
//    if (!ANIsEmpty(model.relatedUser))
//    {
////        [self.interactor updateLastActionForFriend:model.relatedUser]; // TODO: check
//    }
    [self.dataSource updateStorageWithModel:model];
    [self.actionHandler handleEvent:ZZGridActionEventTypeFriendDidAdd];
    [self.userInterface showFriendAnimationWithModel:model.relatedUser];
}

- (void)updateFriendIfNeeded
{
    if (![self.notificationFriend.mkey isEqualToString:self.notifatedFriend.mkey])
    {
        ANDispatchBlockToMainQueue(^{
            CGFloat timeToUpdateInterface = 0.6;
            CGFloat timeAfterAnimationEnd = 3.6;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToUpdateInterface * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                [self.interactor showDownloadAniamtionForFriend:self.notificationFriend];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeAfterAnimationEnd * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.interactor handleNotificationForFriend:self.notificationFriend];
                    self.notifatedFriend = self.notifatedFriend;
                });
            });
        });
    }
}



- (void)_updateFeatures
{
    [self _updateCenterCell];
    [self.dataSource reloadStorage];
}

- (void)_updateCenterCell
{
    if ([self.dataSource centerViewModel])
    {
        id model = [self.dataSource centerViewModel];
        if ([model isKindOfClass:[ZZGridCenterCellViewModel class]])
        {
            [self.userInterface updateSwitchButtonWithState:(![ZZFeatureObserver sharedInstance].isBothCameraEnabled)];
        }
    }
}



#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model
{
    [self.wireframe presentSendFeedbackWithModel:model];
}

- (void)dataLoadedWithArray:(NSArray*)data
{
    [self.dataSource setupWithModels:data];
    ANDispatchBlockAfter(3.f, ^{ //TODO: Get this out here
        ANDispatchBlockToMainQueue(^{
            [self.actionHandler handleEvent:ZZGridActionEventTypeGridLoaded];
        });
    });

    BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    BOOL isSwitchCameraAvailable = [ZZFeatureObserver sharedInstance].isBothCameraEnabled;
    [self.dataSource setupCenterViewModelShouldHandleCameraRotation:(isTwoCamerasAvailable && isSwitchCameraAvailable)];

    [[ZZVideoRecorder shared] updateRecordView:[self.dataSource centerViewModel].recordView];
}

- (void)dataLoadingDidFailWithError:(NSError*)error
{
    //TODO: error
}


- (void)gridContainedFriend:(ZZFriendDomainModel*)friendModel
{
    [self.wireframe closeMenu];
    [ZZGridAlertBuilder showAlreadyConnectedDialogForUser:friendModel.firstName completion:^{
        [self.userInterface showFriendAnimationWithModel:friendModel];
    }];
}

- (void)userHasNoValidNumbers:(ZZContactDomainModel*)model;
{
    [self showNoValidPhonesDialogFromModel:model];
}

- (void)userNeedsToPickPrimaryPhone:(ZZContactDomainModel*)contact
{
    [self showChooseNumberDialogForUser:contact];
}

- (void)userHasNoAppInstalled:(ZZContactDomainModel *)contact
{
    [self _showSendInvitationDialogForUser:contact];
}

- (void)friendRecievedFromServer:(ZZFriendDomainModel*)friendModel
{
    if (friendModel.hasApp)
    {
        [self _showConnectedDialogForModel:friendModel];
    }
    else
    {
        [self _showSmsDialogForModel:friendModel];
    }
}


- (void)loadedStateUpdatedTo:(BOOL)isLoading
{
    [self.userInterface updateLoadingStateTo:isLoading];
}


#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
    [self.userInterface menuWasOpened];
}


#pragma mark - DataSource Delegate

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model
{
    if (!model.item.relatedUser)
    {
        [self presentMenu];
    }
}

- (void)showHint
{
    if ([TBMFriend count] == 0)
    {
        return;
    }
    
    NSString* msg;
    if ([TBMVideo downloadedUnviewedCount] > 0)
    {
        msg = NSLocalizedString(@"hint.center.cell.tap.friend.to.play", nil);
    }
    else
    {
        msg = NSLocalizedString(@"hint.center.cell.press.to.record", nil);
    }
    [ZZGridAlertBuilder showHintalertWithMessage:msg];
}


#pragma mark - Video Player Delegate

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL
{
    //TODO: delete video file
//    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidStartPlaying];
}


- (void)videoPlayerURLWasFinishedPlaying:(NSURL *)videoURL withPlayedUserModel:(ZZFriendDomainModel*)playedFriendModel
{
    [self.interactor updateFriendAfterVideoStopped:playedFriendModel];
    [self.actionHandler handleEvent:ZZGridActionEventTypeMessageDidStopPlaying];
}


#pragma mark - Data source delegate

- (BOOL)isVideoPlaying
{
    return [self.videoPlayer isPlaying];
}

- (void)nudgeSelectedWithUserModel:(ZZFriendDomainModel*)userModel
{
    [self.interactor updateLastActionForFriend:userModel];
    [self _nudgeUser:userModel];
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.isVideoRecorderActive = isEnabled;
    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];
    ZZGridCenterCellViewModel* model = [self.dataSource centerViewModel];
    if (!ANIsEmpty(viewModel.item.relatedUser.idTbm))
    {
        if (isEnabled)
        {
            if ([self.videoPlayer isPlaying])
            {
                [self.videoPlayer stop];
            }
            
            [self.soundPlayer play];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.videoPlayer stop];
                NSURL* url = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:viewModel.item.relatedUser];
                [[ZZVideoRecorder shared] startRecordingWithVideoURL:url];
            });
            model.isRecording = YES;
            
        }
        else
        {
            model.isRecording = NO;
            [[ZZVideoRecorder shared] stopRecordingWithCompletionBlock:^(BOOL isRecordingSuccess) {
                [self.soundPlayer play];
                completionBlock(isRecordingSuccess);
            }];
        }

        [self.userInterface updateRollingStateTo:!isEnabled];
    }
}

- (void)toggleVideoWithViewModel:(ZZGridCellViewModel*)model toState:(BOOL)state
{
    [self.interactor updateLastActionForFriend:model.item.relatedUser];
    
    if (state)
    {
        [self.videoPlayer playOnView:model.playerContainerView withURLs:model.playerVideoURLs];
    }
    else
    {
        [self.videoPlayer stop];
    }
}

- (void)switchCamera
{
    [[ZZVideoRecorder shared] switchCamera];
}

- (void)stopPlaying
{
    [self.videoPlayer stop];
    [self.dataSource reloadStorage];
}

#pragma mark - Module Delegate Method

- (void)userSelectedOnMenu:(id)user
{
    [self.interactor addUserToGrid:user];
}

- (ZZSoundPlayer*)soundPlayer
{
    if (!_soundPlayer)
    {
        _soundPlayer = [[ZZSoundPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
    }
    return _soundPlayer;
}


#pragma mark - Private

- (void)showNoValidPhonesDialogFromModel:(ZZContactDomainModel*)model
{
    [ZZGridAlertBuilder showNoValidPhonesDialogForUserWithFirstName:model.firstName fullName:model.fullName];
}

- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact
{//TODO: category
    TBMAlertController *alert = [TBMAlertController badConnectionAlert];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action) {
        [alert dismissWithCompletion:nil];
    }]];
    
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self.interactor addUserToGrid:contact];
    }]];
    
    [alert presentWithCompletion:nil];
}

- (void)showChooseNumberDialogForUser:(ZZContactDomainModel*)user// TODO: move to grid alerts
{
    ANDispatchBlockToMainQueue(^{
        [[TBMTableModal shared] initWithParentView:self.userInterface.view title:@"Choose phone number" contact:user delegate:self];
        [[TBMTableModal shared] show];
    });
}

#pragma mark - TBMTableModalDelegate

- (void)updatePrimaryPhoneNumberForContact:(ZZContactDomainModel*)contact
{
    [self.interactor userSelectedPrimaryPhoneNumber:contact];
}


- (NSIndexPath*)_indexPathForFriendAtindex:(NSUInteger)friendIndex
{
    NSIndexPath *friendIndexPath = [NSIndexPath indexPathForItem:friendIndex inSection:0];
    return friendIndexPath;
}


#pragma mark - Edit Friends

- (void)friendWasRemovedFromContacts:(ZZFriendDomainModel*)model
{
    [self.interactor removeUserFromContacts:model];
}

- (void)friendWasUnblockedFromContacts:(ZZFriendDomainModel*)model
{
    [self.interactor addUserToGrid:model];
}


#pragma mark - Detail Screens

- (void)presentEditFriendsController
{
    [self.wireframe closeMenu];
    [self.wireframe presentEditFriendsController];
    
}

- (void)presentSendEmailController
{
    [self.interactor loadFeedbackModel];
}


#pragma mark - Video Recorder Delegate

- (void)videoRecordingCanceled
{
    ZZGridCenterCellViewModel* centerCellModel = [self.dataSource centerViewModel];
    centerCellModel.isRecording = NO;
}

@end
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

//@protocol TBMEventsFlowModuleInterface;

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
@property (nonatomic, strong) TBMTableModal *table;
@property (nonatomic, strong) ZZContactDomainModel* contactWithMultiplyPhones;
@property (nonatomic, strong) TBMFriend* notificationFriend;


//shiiiiit
@property (nonatomic, assign) BOOL isGridAppear;
@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController <ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
    self.actionHandler = [ZZGridActionHandler new];
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
                                             selector:@selector(updateGridData:)
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
    [self.actionHandler handleEvent:ZZGridActionEventTypeMessageDidSend];
    [self.dataSource reloadDebugStatuses];
}


#pragma mark - Notifications

- (void)videoStartDownloadingNotification:(NSNotification*)notification
{
    if (![self.videoPlayer isPlaying])
    {
        [self.interactor showDownloadAniamtionForFriend:notification.object];
    }
    else
    {
        self.notificationFriend = notification.object;
    }
    [self.dataSource reloadDebugStatuses];
}

- (void)updateGridData:(NSNotification*)notification
{
    if (![self.videoPlayer isPlaying])
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
    
    [self.dataSource reloadDebugStatuses];
//    TBMFriend* updatedFriend = notification.object;
//    [self.dataSource updateModelWithFriend:updatedFriend];
}

- (void)updateFriendIfNeeded
{
    if (self.notificationFriend)
    {
        ANDispatchBlockToMainQueue(^{
            CGFloat timeToUpdateInterface = 0.6;
            CGFloat timeAfterAnimationEnd = 3.6;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToUpdateInterface * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.interactor showDownloadAniamtionForFriend:self.notificationFriend];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeAfterAnimationEnd * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.interactor handleNotificationForFriend:self.notificationFriend];
                    self.notificationFriend = nil;
                });
            });
        });
    }
}

- (void)updateGridWithModelFromNotification:(ZZGridDomainModel *)model
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
}

- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model
{
    
//    [self.dataSource updateDataSourceWithGridModelFromNotification:model
//                                               withCompletionBlock:^(BOOL isNewVideoDownloaded) {
//           if (isNewVideoDownloaded)
//           {
//               CGFloat animationDelay = 1.8;
//               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                   [self.soundPlayer play];
//               });
//           }
//    }];
    
    [self.dataSource updateDataSourceWithDownloadAnimationWithGridModel:model withCompletionBlock:^(BOOL isNewVideoDownloaded) {
//        if (isNewVideoDownloaded)
//        {
//            CGFloat animationDelay = 1.8;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.soundPlayer play];
//            });
//        }
    }];
    
}

- (void)_updateFeatures
{
    [self _updateCenterCell];
     [self.dataSource reloadDebugStatuses];
}


- (void)_updateCenterCell
{
//    if (self.isGridAppear)
//    {
        if ([self.dataSource centerViewModel])
        {
            id model = [self.dataSource centerViewModel];
            if ([model isKindOfClass:[ZZGridCenterCellViewModel class]])
            {
                [self.userInterface updateSwitchButtonWithState:(![ZZFeatureObserver sharedInstance].isBothCameraEnabled)];
            }
        }
//    }
}

- (void)presentEditFriendsController
{
    [self.wireframe closeMenu];
    [self.wireframe presentEditFriendsController];
   
}

- (void)presentSendEmailController
{
    [self.interactor loadFeedbackModel];
}


#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model
{
    [self.wireframe presentSendFeedbackWithModel:model];
}

- (void)dataLoadedWithArray:(NSArray*)data
{
    [self.dataSource setupWithModels:data completion:^{
        ANDispatchBlockAfter(3.f, ^{ //TODO: Get this out here
            ANDispatchBlockToMainQueue(^{
                [self.actionHandler handleEvent:ZZGridActionEventTypeGridLoaded];
            });
        });
    }];

    BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    BOOL isSwichCameraAvailable = [ZZFeatureObserver sharedInstance].isBothCameraEnabled;
    [self.dataSource setupCenterViewModelShouldHandleCameraRotation:(isTwoCamerasAvailable && isSwichCameraAvailable)];

    [[ZZVideoRecorder shared] updateRecordView:[self.dataSource centerViewModel].recordView];
}

- (void)dataLoadingDidFailWithError:(NSError*)error
{
    //TODO: error
}

- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel*)model
{
    if (!ANIsEmpty(model.relatedUser))
    {
        [self.interactor updateLastActionForFriend:model.relatedUser];
    }
    [self.dataSource selectedViewModelUpdatedWithItem:model];
}


- (void)updateGridWithGridDomainModel:(ZZGridDomainModel *)model
{
    if (!ANIsEmpty(model.relatedUser))
    {
        [self.interactor updateLastActionForFriend:model.relatedUser];
    }
    [self.dataSource updateModel:model];
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
    [self showSendInvitationDialogForUser:contact];
}

- (void)friendRecievedFromServer:(ZZFriendDomainModel*)friendModel
{
    if (friendModel.hasApp)
    {
        [self showConnectedDialogForModel:friendModel];
    }
    else
    {
        [self showSmsDialogForModel:friendModel];
    }
}

- (void)updateGridWithModel:(ZZGridDomainModel*)model
{
    if (!ANIsEmpty(model.relatedUser))
    {
        [self.interactor updateLastActionForFriend:model.relatedUser];
    }
    [self.dataSource updateStorageWithModel:model];
    [self.actionHandler handleEvent:ZZGridActionEventTypeFriendDidAdd];
    [self.userInterface showFriendAnimationWithModel:model.relatedUser];
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
    if (model.item.relatedUser)
    {
//        model.item.relatedUser.timeOfLastAction = [NSDate date]; //TODO:
//        [[TBMVideoPlayer sharedInstance] togglePlayWithIndex:[self indexWithView:view] frame:view.frame];
    }
    else
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
    
    [ZZGridAlertBuilder showPreNudgeAlertWithFriendFirstName:userModel.firstName completion:^{
        [self showSmsDialogForModel:userModel];
    }];
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock // TODO: add states for gesture recognizer and show toasts
{
    
    
    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];
    ZZGridCenterCellViewModel* model = [self.dataSource centerViewModel];
    if (!ANIsEmpty(viewModel.item.relatedUser.idTbm))
    {
        if (isEnabled)
        {
            //OLD
            //            TBMGridElement *ge = [self gridElementWithView:view];
            //            if (ge.friend != nil) {
            //                [self rankingActionOccurred:ge.friend];
            //                [[TBMVideoPlayer sharedInstance] stop];
            //                NSURL *videoUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriend:ge.friend];
            //                [[self videoRecorder] startRecordingWithVideoUrl:videoUrl];
            //            }
            
            
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
        {//OLD
            //            TBMGridElement *ge = [self gridElementWithView:view];
            //            if (ge.friend != nil) {
            //                [[self videoRecorder] stopRecording];
            //            }
            model.isRecording = NO;
            [[ZZVideoRecorder shared] stopRecordingWithCompletionBlock:^(BOOL isRecordingSuccess) {
                [self.soundPlayer play];
                completionBlock(isRecordingSuccess);
            }];
        }
        // TODO: add states of gesture and hanlde cancel situatuin
        //        - (void)LPTHCancelLongPressWithTargetView:(UIView *)view reason:(NSString *)reason
        //        {
        //            TBMGridElement *ge = [self gridElementWithView:view];
        //            if (ge.friend != nil) {
        //                if ([[self videoRecorder] cancelRecording]) {
        //                    [[iToast makeText:reason] show];
        //                    [self performSelector:@selector(toastNotSent) withObject:nil afterDelay:1.2];
        //                }
        //            }
        //        }
        
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
     [self.dataSource reloadDebugStatuses];
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

#pragma mark - View delegate

- (void)gridDidAppear
{
    //[self.eventsFlowModule throwEvent:TBMEventFlowEventApplicationDidLaunch];
    self.isGridAppear = YES;
}

#pragma mark - Private

//TODO:
- (void)toastNotSent
{
    [[iToast makeText:@"Not sent"] show];
}

- (void)showNoValidPhonesDialogFromModel:(ZZContactDomainModel*)model
{
    [ZZGridAlertBuilder showNoValidPhonesDialogForUserWithFirstName:model.firstName fullName:model.fullName];
}

- (void)showChooseNumberDialogForUser:(ZZContactDomainModel*)user// TODO: move to grid alerts
{
    self.contactWithMultiplyPhones = user;
   
    ANDispatchBlockToMainQueue(^{
        self.table = [[TBMTableModal alloc] initWithParentView:self.userInterface.view title:@"Choose phone number" rowData:user.phones delegate:self];
        [self.table show];
    });
}

- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact
{
    TBMAlertController *alert = [TBMAlertController badConnectionAlert];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action) {
        [alert dismissWithCompletion:nil];
    }]];
    
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self.interactor addUserToGrid:contact];
    }]];
    
    [alert presentWithCompletion:nil];
}


#pragma mark - TBMTableModalDelegate

- (void) didSelectRow:(NSInteger)index
{
    self.contactWithMultiplyPhones.primaryPhone = self.contactWithMultiplyPhones.phones[index];
    [self.interactor userSelectedPrimaryPhoneNumber:self.contactWithMultiplyPhones];
}

- (void)showSendInvitationDialogForUser:(ZZContactDomainModel*)user
{
    [ZZGridAlertBuilder showSendInvitationDialogForUser:user.firstName completion:^ {
        [self.interactor inviteUserInApplication:user];
    }];
}

- (void)showConnectedDialogForModel:(ZZFriendDomainModel*)friend
{
    [self.interactor updateLastActionForFriend:friend];
    
    [ZZGridAlertBuilder showConnectedDialogForUser:friend.firstName completion:^{
        [self.interactor addUserToGrid:friend];
    }];
}

- (void)showSmsDialogForModel:(ZZFriendDomainModel*)friend
{
    ANMessageDomainModel* model = [ANMessageDomainModel new];
    NSString* formattedNumber = [TBMPhoneUtils phone:friend.mobileNumber withFormat:NBEPhoneNumberFormatE164];
    model.recipients = @[[NSObject an_safeString:formattedNumber]];

    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    model.message = [NSString stringWithFormat:@"I sent you a message on %@. Get the app: %@%@", appName, kInviteFriendBaseURL, [ZZUserDataProvider authenticatedUser].idTbm];
    
    [self.wireframe presentSMSDialogWithModel:model success:^{
        [self showConnectedDialogForModel:friend];
    } fail:^{
        [self showCantSendSmsErrorForModel:friend];
    }];
}

- (void)showCantSendSmsErrorForModel:(ZZFriendDomainModel*)friend
{
    [ZZGridAlertBuilder showCannotSendSmsErrorToUser:[friend fullName] completion:^{
        [self showConnectedDialogForModel:friend];
    }];
}

- (NSIndexPath*)_indexPathForFriendAtindex:(NSUInteger)friendIndex
{
    NSIndexPath *friendIndexPath = [NSIndexPath indexPathForItem:friendIndex inSection:0];
    return friendIndexPath;
}


#pragma mark - Edit Friends

- (void)friendRemovedContacts:(ZZFriendDomainModel*)model
{
    [self.interactor removeUserFromContacts:model];
}

- (void)restoreFriendAtGrid:(ZZFriendDomainModel*)model
{
    [self.interactor addUserToGrid:model];
}


#pragma mark - Video Recorder Delegate

- (void)videoRecordingCanceled
{
    ZZGridCenterCellViewModel* centerCellModel = [self.dataSource centerViewModel];
    centerCellModel.isRecording = NO;
}

@end
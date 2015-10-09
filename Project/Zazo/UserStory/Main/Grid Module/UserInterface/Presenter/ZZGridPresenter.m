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
#import "TBMAlertController.h"
#import "TBMAppDelegate.h"
#import "ZZFeatureObserver.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridActionHandler.h"
#import "TBMTableModal.h"
#import "ZZCoreTelephonyConstants.h"
#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"


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
    
    [[ZZVideoRecorder shared] addDelegate:self];
}

- (void)_setupNotifications
{
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZZVideoRecorder shared] removeDelegate:self];
}

- (void)sendMessageEvent
{
//    [self.actionHandler handleEvent:ZZGridActionEventTypeMessageDidSent];
}

#pragma mark - Notifications

- (void)reloadGridWithData:(NSArray*)data
{
    if (![ZZVideoRecorder shared].isRecorderActive && !self.videoPlayer.isPlayingVideo)
    {
        [self.dataSource setupWithModels:data];
    }
}

- (void)updateGridWithModelFromNotification:(ZZGridDomainModel *)model isNewFriend:(BOOL)isNewFriend
{
    [self.dataSource updateCellWithModel:model];
    if (model.relatedUser.outgoingVideoStatusValue != OUTGOING_VIDEO_STATUS_VIEWED)
    {
        [self.soundPlayer play]; // TODO: check
    }
    
    if (isNewFriend)
    {
        model.isDownloadAnimationViewed = YES;
        [self.userInterface showFriendAnimationWithIndex:[self.dataSource viewModelIndexWithModelIndex:model.index]];
//        [self.actionHandler handleEvent:ZZGridActionEventTypeFriendAddedToGrid];
    }
}

- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model
{
//    [self.actionHandler handleEvent:ZZGridActionEventTypeIncomingMessageDidReceived]; // TODO:
    [self.dataSource updateCellWithModel:model];
}


#pragma mark - Update User

- (void)reloadGridModel:(ZZGridDomainModel*)model
{
    [self.dataSource updateCellWithModel:model];

}

- (void)updateGridWithModel:(ZZGridDomainModel*)model isNewFriend:(BOOL)isNewFriend
{
    model.isDownloadAnimationViewed = YES;
    [self.dataSource updateCellWithModel:model];
    NSInteger index = [self.dataSource viewModelIndexWithModelIndex:model.index];
    [self.userInterface showFriendAnimationWithIndex:index];
    
    if (isNewFriend)
    {
//        [self.actionHandler handleEvent:ZZGridActionEventTypeFriendDidAdd];
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


#pragma makr - EVENT InviteHint

- (void)dataLoadedWithArray:(NSArray*)data
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupWithModels:data];
        [self _handleInviteEvent];
        
        BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
        BOOL isSwitchCameraAvailable = [ZZGridActionStoredSettings shared].frontCameraHintWasShown;
        
        [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable && isSwitchCameraAvailable)];
        
        [[ZZVideoRecorder shared] updateRecordView:[self.dataSource centerViewModel].recordView];
    });
}

- (void)dataLoadingDidFailWithError:(NSError*)error
{
    //TODO: error
}


- (void)gridAlreadyContainsFriend:(ZZGridDomainModel*)model
{
    [self.wireframe closeMenu];
    [ZZGridAlertBuilder showAlreadyConnectedDialogForUser:model.relatedUser.firstName completion:^{
        model.isDownloadAnimationViewed = YES;
        [self.dataSource updateCellWithModel:model];
        [self.userInterface showFriendAnimationWithIndex:[self.dataSource viewModelIndexWithModelIndex:model.index]];
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

- (void)addUser
{
    [self presentMenu];
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

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL{}

- (void)videoPlayerURLWasFinishedPlaying:(NSURL *)videoURL withPlayedUserModel:(ZZFriendDomainModel*)playedFriendModel
{
    [self.interactor updateFriendAfterVideoStopped:playedFriendModel];
    [self _handleRecordHintWithCellViewModel:playedFriendModel];
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
    [ZZVideoRecorder shared].isRecorderActive = isEnabled;
    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];
    if (!ANIsEmpty(viewModel.item.relatedUser.idTbm))
    {
        if (isEnabled)
        {
            if ([self.videoPlayer isPlaying])
            {
                [self.videoPlayer stop];
            }
            
            [self.soundPlayer play];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.videoPlayer stop];
                NSURL* url = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:viewModel.item.relatedUser];
                [self.userInterface updateRecordViewStateTo:isEnabled];

                [[ZZVideoRecorder shared] startRecordingWithVideoURL:url completionBlock:^(BOOL isRecordingSuccess) {
                    [self.userInterface updateRecordViewStateTo:NO];
                    [self.soundPlayer play];
                   
                    completionBlock(isRecordingSuccess);
                }];
            });
        }
        else
        {
            [[ZZVideoRecorder shared] stopRecordingWithCompletionBlock:^(BOOL isRecordingSuccess) {
                [self.userInterface updateRecordViewStateTo:isEnabled];
                [self.soundPlayer play];
                if (isRecordingSuccess)
                {
                    [self _handleSentMessageEventWithCellViewModel:viewModel];
                }
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
//    [self.dataSource reloadStorage];
}

#pragma mark - Menu Delegate

- (void)userSelectedOnMenu:(id)user
{
    [self.interactor addUserToGrid:user];
}


#pragma mark - Invites

- (void)showNoValidPhonesDialogFromModel:(ZZContactDomainModel*)model
{
    [self _showNoValidPhonesDialogFromModel:model];
}

- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact
{
    [self _addingUserToGridDidFailWithError:error forUser:contact];
}

- (void)showChooseNumberDialogForUser:(ZZContactDomainModel*)user
{
    [self _showChooseNumberDialogForUser:user];
}

#pragma mark - TBMTableModalDelegate

- (void)updatePrimaryPhoneNumberForContact:(ZZContactDomainModel*)contact
{
    [self.interactor userSelectedPrimaryPhoneNumber:contact];
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
    [self.wireframe presentEditFriendsController];
}

- (void)presentSendEmailController
{
    [self.interactor loadFeedbackModel];
}


#pragma mark - Video Recorder Delegate

- (void)videoRecordingCanceled
{
    [self.userInterface updateRecordViewStateTo:NO];
}

- (ZZSoundPlayer*)soundPlayer
{
    if (!_soundPlayer)
    {
        _soundPlayer = [[ZZSoundPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
    }
    return _soundPlayer;
}


#pragma mark - Action Handler Delegate

- (void)unlockedFeature:(ZZGridActionFeatureType)feature
{
    if (feature == ZZGridActionFeatureTypeSwitchCamera)
    {
        [self.userInterface updateSwitchButtonWithState:NO];
    }
}

- (id)modelAtIndex:(NSInteger)index
{
    id model = [self.dataSource viewModelAtIndex:index];
    return model;

}

#pragma mark - Interactor Action Handler

- (void)handleModel:(ZZGridDomainModel *)model withEvent:(ZZGridActionEventType)event
{
    [self _handleEvent:event withDomainModel:model];
}

- (NSInteger)friendsNumberOnGrid
{
    return [self.dataSource frindsOnGridNumber];
}

@end
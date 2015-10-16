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
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridActionHandler.h"
#import "TBMTableModal.h"
#import "ZZCoreTelephonyConstants.h"
#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZSecretConstants.h"


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
                                             selector:@selector(stopPlaying)
                                                 name:kNotificationIncomingCall
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleAppBeomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_reloadDataAfterResetAllUserDataNotification)
                                                 name:kResetAllUserDataNotificationKey object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZZVideoRecorder shared] removeDelegate:self];
}


#pragma mark - Notifications

- (void)_reloadDataAfterResetAllUserDataNotification
{
    [self.interactor reloadDataAfterResetUserData];
}

- (void)reloadGridAfterClearUserDataWithData:(NSArray *)data
{
    [self.dataSource setupWithModels:data];
}

- (void)reloadGridWithData:(NSArray*)data
{
    if (![ZZVideoRecorder shared].isRecorderActive && !self.videoPlayer.isPlayingVideo)
    {
        [self.dataSource setupWithModels:data];
    }
}

- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model
{
    [self.dataSource updateCellWithModel:model];
}

- (void)_handleAppBeomeActive
{
    [self.actionHandler resetLastHintAndShowIfNeeded];
}

- (void)_handleResignActive
{
    [self.actionHandler hideHint];
}

#pragma mark - Update User

- (void)reloadGridModel:(ZZGridDomainModel*)model
{
    [self.dataSource updateCellWithModel:model];
}

- (void)reloadAfterVideoUpdateGridModel:(ZZGridDomainModel *)model
{
    if ([self _isAbleToUpdateWithModel:model])
    {
        [self.dataSource updateCellWithModel:model];
        
        if (model.relatedUser.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
            model.relatedUser.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED )
        {
            CGFloat delayAfterDownloadAnimationCompleted = 1.6f;
            ANDispatchBlockAfter(delayAfterDownloadAnimationCompleted, ^{
                [self.soundPlayer play];
            });
        }
    }
}

- (void)updateGridWithModel:(ZZGridDomainModel*)model isNewFriend:(BOOL)isNewFriend
{
    if ([self _isAbleToUpdateWithModel:model])
    {
        model.isDownloadAnimationViewed = YES;
        [self.dataSource updateCellWithModel:model];
        //TODO:
        //    if (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED)
        //    {
        //        [self.soundPlayer play]; // TODO: check
        //    }
        
        if (isNewFriend)
        {
            NSInteger index = [self.dataSource viewModelIndexWithModelIndex:model.index];
            [self.userInterface showFriendAnimationWithIndex:index];
        }
    }
}

- (BOOL)_isAbleToUpdateWithModel:(ZZGridDomainModel*)model
{
    BOOL isAbleUpdte = YES;
    
    if (self.videoPlayer.isPlayingVideo &&
        [[self.videoPlayer playedFriendModel].idTbm isEqualToString:model.relatedUser.idTbm])
    {
        if (model.relatedUser.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED)
        {
            [self.videoPlayer updateWithFriendModel:model.relatedUser];
        }
        
        isAbleUpdte = NO;
    }
    
    return isAbleUpdte;
}


#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model
{
    [self.wireframe presentSendFeedbackWithModel:model];
}

- (void)updatedFeatureWithFriendMkeys:(NSArray *)friendsMkeys
{
    [self.actionHandler updateFeaturesWithFriendsMkeys:friendsMkeys];
}


#pragma makr - EVENT InviteHint

- (void)dataLoadedWithArray:(NSArray*)data
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupWithModels:data];
        [self _handleInviteEvent];
        
        BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
        BOOL isSwitchCameraAvailable = [ZZGridActionStoredSettings shared].frontCameraHintWasShown;
        
        [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable &&
                                                                          isSwitchCameraAvailable &&
                                                                          [ZZGridActionStoredSettings shared].frontCameraHintWasShown)];
        
        [[ZZVideoRecorder shared] updateRecorder];
        [[ZZVideoRecorder shared] updateRecordView:[self.dataSource centerViewModel].recordView];
        [self _showRecordWelcomeIfNeeded];
    });
}

- (void)updateSwithCameraFeatureIsEnabled:(BOOL)isEnabled
{
    BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable && isEnabled)];
}

- (void)_showRecordWelcomeIfNeeded
{
    CGFloat kDelayAfterViewLoaded = 0.8f;
    ANDispatchBlockAfter(kDelayAfterViewLoaded, ^{
        NSInteger indexWhenOneFriendOnGrid = 5;
        [self.actionHandler handleEvent:ZZGridActionEventTypeGridLoaded withIndex:indexWhenOneFriendOnGrid];
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
    if (![ZZVideoRecorder shared].isRecordingInProgress)
    {
        [self.actionHandler hideHint];
        [self.wireframe toggleMenu];
        [self.userInterface menuWasOpened];
    }
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
    if (![ZZVideoRecorder shared].isRecordingInProgress)
    {
        [self.interactor updateLastActionForFriend:userModel];
        [self _nudgeUser:userModel];
    }
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
            [self.actionHandler hideHint];
            if ([self.videoPlayer isPlaying])
            {
                [self.videoPlayer stop];
            }
            
            [self.soundPlayer play];
            [ZZVideoRecorder shared].wasRecordingStopped = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (![ZZVideoRecorder shared].wasRecordingStopped)
                {
                    [self.videoPlayer stop];
                    NSURL* url = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:viewModel.item.relatedUser];
                    [self.userInterface updateRecordViewStateTo:isEnabled];
                    
                    [[ZZVideoRecorder shared] startRecordingWithVideoURL:url completionBlock:^(BOOL isRecordingSuccess) {
                        [self.userInterface updateRecordViewStateTo:NO];
                        [self.soundPlayer play];
                        
                        completionBlock(isRecordingSuccess);
                    }];
                }
            });
        }
        else
        {
            [ZZVideoRecorder shared].wasRecordingStopped = YES;
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

- (void)friendStateWasUpdated:(ZZFriendDomainModel *)model toVisible:(BOOL)isVisible
{
    [self.interactor friendWasUpdatedFromEditContacts:model toVisible:isVisible];
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

- (BOOL)isRecordingInProgress
{
    return [ZZVideoRecorder shared].isRecordingInProgress;
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
        BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
        BOOL isSwitchCameraAvailable = [ZZGridActionStoredSettings shared].frontCameraHintWasShown;
        [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable &&
                                                                          isSwitchCameraAvailable &&
                                                                          [ZZGridActionStoredSettings shared].frontCameraHintWasShown)];
        
    }
}

- (id)modelAtIndex:(NSInteger)index
{
    id model = [self.dataSource viewModelAtIndex:index];
    return model;

}

- (NSInteger)friendsCountOnGrid
{
    return [self.dataSource frindsOnGridNumber];
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

- (BOOL)isVideoPlayingNow
{
    return self.videoPlayer.isPlayingVideo;
}

@end
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
#import "ZZVideoPlayer.h"
#import "ZZContactDomainModel.h"
#import "ZZAPIRoutes.h"
#import "ZZGridAlertBuilder.h"
#import "ZZUserDataProvider.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridActionHandler.h"
#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZSoundEffectPlayer.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataHelper.h"
#import "ZZVideoDomainModel.h"
#import "ZZRootStateObserver.h"

#import "TBMAlertController.h"
#import "TBMTableModal.h"
#import "TBMVideoIdUtils.h"

#import "RollbarReachability.h"
#import "iToast.h"


@interface ZZGridPresenter ()
<
    ZZGridDataSourceDelegate,
    ZZVideoPlayerDelegate,
    ZZGridActionHanlderDelegate,
    TBMTableModalDelegate
>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZSoundEffectPlayer* soundPlayer;
@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;
@property (nonatomic, strong) ZZGridActionHandler* actionHandler;
@property (nonatomic, strong) RollbarReachability* reachability;
@property (nonatomic, strong) ZZGridAlertBuilder* alertBuilder;

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
    self.reachability = [RollbarReachability reachabilityForInternetConnection];
}

- (void)attachToMenuPanGesture:(UIPanGestureRecognizer*)pan
{
    [self.wireframe attachAdditionalPanGestureToMenu:pan];
}

- (void)_setupNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleAppBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_reloadDataAfterResetAllUserDataNotification)
                                                 name:kResetAllUserDataNotificationKey
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateViewPositions)
                                                 name:UIApplicationWillResignActiveNotification //UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (![[ZZVideoRecorder shared] isRecording] && !self.videoPlayer.isPlayingVideo)
    {
        [self.dataSource setupWithModels:data];
    }
}

- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model
{
    [self.dataSource updateCellWithModel:model];
}

- (void)_handleAppBecomeActive
{
    [self.actionHandler resetLastHintAndShowIfNeeded];
    [self.interactor updateGridIfNeeded];
}

- (void)_handleResignActive
{
    [self.actionHandler hideHint];
}

- (void)_updateViewPositions
{
    [self.userInterface configureViewPositions];
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
        
        if (model.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
            model.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded )
        {
            CGFloat delayAfterDownloadAnimationCompleted = 1.6f;
            ANDispatchBlockAfter(delayAfterDownloadAnimationCompleted, ^{
                if (!self.videoPlayer.isPlayingVideo)
                {
                    [self.soundPlayer play];
                }
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
        [self showFriendAnimationWithFriend:model.relatedUser];
        [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventFriendWasAddedToGridWithVideo
                                           notificationObject:nil];
        //TODO:
        //    if (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED)
        //    {
        //        [self.soundPlayer play]; // TODO: check
        //    }
        
//        if (isNewFriend)
//        {
//            NSInteger index = [self.dataSource viewModelIndexWithModelIndex:model.index];
//            [self.userInterface showFriendAnimationWithIndex:index];
//        }
    }
}

- (void)showFriendAnimationWithFriend:(ZZFriendDomainModel *)friendModel
{
    [self.userInterface showFriendAnimationWithFriendModel:friendModel];
}

- (BOOL)_isAbleToUpdateWithModel:(ZZGridDomainModel*)model
{
    BOOL isAbleUpdte = YES;
  
    if ([[self.videoPlayer playedFriendModel].idTbm isEqualToString:model.relatedUserID])
    {
        if (model.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
        {
            [self.videoPlayer updateWithFriendModel:model.relatedUser];
        }
        
        isAbleUpdte = NO;
    }
    
    return isAbleUpdte;
}

- (void)updatePositionsForGirdModels:(NSArray *)models
{
    [self.userInterface configureViewPositions];
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

- (void)updateFriendThatPrevouslyWasOnGridWithModel:(ZZFriendDomainModel *)model
{
     [self _handleSentWelcomeHintWithFriendDomainModel:model];
}


#pragma mark - EVENT InviteHint

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
        
        [[ZZVideoRecorder shared] setup];
        [self.dataSource updateValueOnCenterCellWithPreviewLayer:[ZZVideoRecorder shared].previewLayer];
        [[ZZVideoRecorder shared] startPreview];
        
        [self _showRecordWelcomeIfNeededWithData:data];
    });
}

- (void)updateSwithCameraFeatureIsEnabled:(BOOL)isEnabled
{
    BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable && isEnabled)];
}

- (void)_showRecordWelcomeIfNeededWithData:(NSArray*)data
{
    if([ZZFriendDataProvider friendsOnGrid].count == 1)
    {
        CGFloat kDelayAfterViewLoaded = 1.5f;
        ANDispatchBlockAfter(kDelayAfterViewLoaded, ^{
            NSInteger indexWhenOneFriendOnGrid = 5;
            ZZFriendDomainModel* model = [[ZZFriendDataProvider friendsOnGrid] firstObject];
            [self.actionHandler handleEvent:ZZGridActionEventTypeGridLoaded withIndex:indexWhenOneFriendOnGrid friendModel:model];
        });
    }
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
        [self.userInterface showFriendAnimationWithFriendModel:model.relatedUser];
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
        [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
        
    }
    else
    {
        [self _showSmsDialogForModel:friendModel isNudgeAction:NO];
    }
}

- (void)loadedStateUpdatedTo:(BOOL)isLoading
{
    [self.userInterface updateLoadingStateTo:isLoading];
}

- (NSInteger)indexOnGridViewForFriendModel:(ZZFriendDomainModel *)model
{
    return [self.userInterface indexOfFriendModelOnGridView:model];
}

#pragma mark - Module Interface

- (void)presentMenu
{
    if (![[ZZVideoRecorder shared] isRecording])
    {
        [self.actionHandler hideHint];
        [self.wireframe toggleMenu];
        [self.userInterface menuWasOpened];
    }
}

- (void)hideHintIfNeeded
{
    [self.actionHandler hideHint];
}

- (void)updatePositionForViewModels:(NSArray *)models
{
    [self.interactor updateGridViewModels:models];
}


#pragma mark - DataSource Delegate

- (void)showRecorderHint
{
    [ZZGridAlertBuilder showOneTouchRecordViewHint];
}

- (BOOL)isGridRotate
{
    return [self.userInterface isGridRotating];
}

- (void)addUser
{
    [self presentMenu];
}

- (void)showHint
{
    if ([ZZFriendDataProvider friendsCount] == 0)
    {
        return;
    }
    
    NSString* msg;
    
    if ([ZZVideoDataProvider countDownloadedUnviewedVideos] > 0)
    {
        msg = NSLocalizedString(@"hint.center.cell.tap.friend.to.play", nil);
    }
    else
    {
        msg = NSLocalizedString(@"hint.center.cell.press.to.record", nil);
    }
    [ZZGridAlertBuilder showHintalertWithMessage:msg];
}

- (BOOL)isNetworkEnabled
{
    return [self _isNetworkEnabled];
}

- (void)_showToastWithMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}

- (BOOL)isVideoPlayingEnabledWithModel:(ZZGridCellViewModel *)model
{
    
    BOOL isEnabled = YES;

        if ([self _isNetworkEnabled])
        {
            if ((model.badgeNumber == 0) &&
                model.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
            {
                isEnabled = NO;
                [self _showToastWithMessage:NSLocalizedString(@"video-playing-disabled-reason-downloading", nil)];
            }
        }
        else
        {
            if (model.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading && model.badgeNumber == 0)
            {
                isEnabled = NO;
                
                NSString* badConnectionTitle = NSLocalizedString(@"internet-connection-error-title", nil);
                NSString* message = NSLocalizedString(@"internet-connection-error-message", nil);
                NSString* actionButtonTitle = NSLocalizedString(@"internet-connection-error-button-title", nil);
                [ZZGridAlertBuilder showAlertWithTitle:badConnectionTitle
                                               message:message
                                     cancelButtonTitle:nil
                                    actionButtonTitlte:actionButtonTitle action:^{}];
            
            }
            else
            {
                isEnabled = YES;
            }
        }

    return isEnabled;
}


- (BOOL)_isNetworkEnabled
{
    return [self.reachability isReachable];
}


#pragma mark - Video Player Delegate

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL{}

- (void)videoPlayerURLWasFinishedPlaying:(NSURL *)videoURL withPlayedUserModel:(ZZFriendDomainModel*)playedFriendModel
{
    [self.interactor updateFriendAfterVideoStopped:playedFriendModel];
    [self _handleRecordHintWithCellViewModel:playedFriendModel];
}


#pragma mark - Data source delegate

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel *)friendModel
{
    return  [self.videoPlayer isVideoPlayingWithFriendModel:friendModel];
}

- (void)nudgeSelectedWithUserModel:(ZZFriendDomainModel*)userModel
{
    if (![[ZZVideoRecorder shared] isRecording])
    {
        [self.interactor updateLastActionForFriend:userModel];
        [self _nudgeUser:userModel];
    }
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    ZZLogInfo(@"recordingStateUpdatedToState:%d", isEnabled);

    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];

    if (!ANIsEmpty(viewModel.item.relatedUserID))
    {
        
        if (isEnabled)
        {
            [self.actionHandler hideHint];
            if ([self.videoPlayer isPlaying])
            {
                [self.videoPlayer stop];
            }
            
            ANDispatchBlockToMainQueue(^{
                [self.videoPlayer stop];
                NSURL* url = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:viewModel.item.relatedUserID];

                [self.userInterface updateRecordViewStateTo:isEnabled];
                
                [[ZZVideoRecorder shared] startRecordingWithVideoURL:url completionBlock:^(BOOL isRecordingSuccess) {
                    [self.userInterface updateRecordViewStateTo:NO];
                    
                    completionBlock(isRecordingSuccess);
                }];
            });
        }
        else
        {
            ANDispatchBlockToMainQueue(^{
                // Don't rely on completion by videoRecorder to reset the view in case
                // for some reason it does not complete.
                [self.userInterface updateRecordViewStateTo:isEnabled];
                
                [[ZZVideoRecorder shared] stopRecordingWithCompletionBlock:^(BOOL isRecordingSuccess) {
                    if (isRecordingSuccess)
                    {
                        [self _handleSentMessageEventWithCellViewModel:viewModel];
                    }
                    completionBlock(isRecordingSuccess);
                }];

            });
        }

        [self.userInterface updateRollingStateTo:!isEnabled];
    }
}

- (void)cancelRecordingWithReason:(NSString *)reason
{
    [[ZZVideoRecorder shared] cancelRecordingWithReason:reason];
    [self.userInterface updateRecordViewStateTo:NO];
}

- (void)toggleVideoWithViewModel:(ZZGridCellViewModel*)model toState:(BOOL)state
{
    ZZFriendDomainModel *friend = model.item.relatedUser;
    [self.interactor updateLastActionForFriend:friend];
    
    NSArray *videos = friend.videos;
    
    if (state)
    {
        [self.videoPlayer playOnView:model.playerContainerView withVideoModels:videos];
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
    return [[ZZVideoRecorder shared] isRecording];
}


- (ZZSoundEffectPlayer*)soundPlayer
{
    if (!_soundPlayer)
    {
        _soundPlayer = [[ZZSoundEffectPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
    }
    return _soundPlayer;
}

- (UIView *)recordingView
{
    return [self.dataSource centerViewModel].recordView;
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

- (ZZGridAlertBuilder *)alertBuilder
{
    if (!_alertBuilder)
    {
        _alertBuilder = [ZZGridAlertBuilder new];
    }
    
    return _alertBuilder;
}

@end
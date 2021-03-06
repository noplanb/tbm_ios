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
#import "iToast.h"
#import "ZZContactDomainModel.h"
#import "ZZGridAlertBuilder.h"
#import "ZZGridActionHandler.h"
#import "ZZTableModal.h"
#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZSoundEffectPlayer.h"
#import "ZZVideoDataProvider.h"
#import "TBMVideoIdUtils.h"
#import "ZZFriendDataProvider.h"
#import "RollbarReachability.h"
#import "ZZVideoDomainModel.h"
#import "ZZRootStateObserver.h"
#import "ZZGridDataProvider.h"
#import "ZZMainWireframe.h"
#import "ZZMainModuleInterface.h"
#import "ZZSettingsManager.h"
#import "ZZThumbnailGenerator.h"
#import "ZZAbilities.h"

@interface ZZGridPresenter ()
        <
        ZZGridDataSourceDelegate,
        ZZGridActionHanlderDelegate,
        TBMTableModalDelegate,
        ZZGridModelPresenterInterface
        >

@property (nonatomic, strong) ZZGridDataSource *dataSource;
@property (nonatomic, strong) ZZSoundEffectPlayer *soundPlayer;
@property (nonatomic, strong) ZZGridActionHandler *actionHandler;
@property (nonatomic, strong) RollbarReachability *reachability;
@property (nonatomic, strong) ZZGridAlertBuilder *alertBuilder;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController <ZZGridViewInterface> *)userInterface
{
    self.userInterface = userInterface;

    self.actionHandler = [ZZGridActionHandler new];
    self.actionHandler.delegate = self;
    self.actionHandler.userInterface = self.userInterface;

    ZZGridDataSource *dataSource = [ZZGridDataSource new];
    dataSource.delegate = self;
    dataSource.presenter = self;
    dataSource.thumbProvider = self.interactor;
    self.dataSource = dataSource;
    
    [self.userInterface updateWithDataSource:self.dataSource];

    [self _setupNotifications];
    [self.interactor loadData];
    self.reachability = [RollbarReachability reachabilityForInternetConnection];
    
    [self _startTouchObserve];
}

- (void)setVideoPlayer:(id<ZZPlayerModuleInterface>)videoPlayer
{
    _videoPlayer = videoPlayer;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartPreview:)
                                                 name:kZZVideoRecorderDidStartPreview
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ZZGridCellViewModel *)_cellForFriend:(ZZFriendDomainModel *)friendModel
{
    if (!friendModel)
    {
        return nil;
    }
    
    NSInteger cellModelIndex = [self.dataSource indexForFriendDomainModel:friendModel];
    
    if (cellModelIndex == NSNotFound)
    {
        return nil;
    }
    
    ZZGridCellViewModel *cellModel = [self.dataSource viewModelAtIndex:cellModelIndex];

    return cellModel;
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

- (void)reloadGridWithData:(NSArray *)data
{
    if (![[ZZVideoRecorder shared] isRecording] && !self.videoPlayer.isPlayingVideo)
    {
        [self.dataSource setupWithModels:data];
    }
}

- (void)_handleAppBecomeActive
{
    [self.actionHandler resetLastHintAndShowIfNeeded];
    [self.interactor updateGridIfNeeded];

    if ([ZZVideoRecorder shared].isCameraSwitched)
    {
        [[ZZVideoRecorder shared] switchCamera:nil];
    }
}

- (void)_handleResignActive
{
    [self.actionHandler hideHint];
}

- (void)_updateViewPositions
{
    [self.userInterface configureViewPositions];
}

- (void)didStartPreview:(NSNotification *)note
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource updateValueOnCenterCellWithPreviewLayer:note.object];
    });
}

#pragma mark - Update User

- (void)reloadGridModel:(ZZGridDomainModel *)model
{
    [self.dataSource updateCellWithModel:model];
}

- (void)reloadAfterMessageUpdateGridModel:(ZZGridDomainModel *)gridModel
{
    [self.dataSource updateCellWithModel:gridModel];
    
    if (gridModel.relatedUser.messages.lastObject.status == ZZMessageStatusNew &&
        gridModel.relatedUser.messages.lastObject.type == ZZMessageTypeText)
    {
        if (!self.videoPlayer.isPlayingVideo && ![ZZVideoRecorder shared].isRecording)
        {
            [self.soundPlayer play];
        }
    }

}

- (void)reloadAfterVideoUpdateGridModel:(ZZGridDomainModel *)gridModel
{
    [self.dataSource updateCellWithModel:gridModel];

    if (gridModel.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
            gridModel.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        CGFloat delayAfterDownloadAnimationCompleted = 1.6f;
        ANDispatchBlockAfter(delayAfterDownloadAnimationCompleted, ^{
            if (!self.videoPlayer.isPlayingVideo && ![ZZVideoRecorder shared].isRecording)
            {
                [self.soundPlayer play];
            }
        });
    }
}

- (void)updateGridWithModel:(ZZGridDomainModel *)model animated:(BOOL)animated
{
    if (!model)
    {
        return;
    }
    
    if ([self _isAbleToUpdateWithModel:model])
    {
//        model.isDownloadAnimationViewed = YES;
        [self.dataSource updateCellWithModel:model];
        
        if (animated)
        {
            [self showFriendAnimationWithFriend:model.relatedUser];
        }
        
        [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventFriendWasAddedToGridWithVideo
                                           notificationObject:nil];

        // Update first grid cell to let it show active icon
        ZZGridDomainModel *firstEmpty = [ZZGridDataProvider loadFirstEmptyGridElement];
        
        if (firstEmpty)
        {
            [self.dataSource updateCellWithModel:firstEmpty];
        }
    }
}

- (void)showFriendAnimationWithFriend:(ZZFriendDomainModel *)friendModel
{
    [self.userInterface showFriendAnimationWithFriendModel:friendModel];
}

- (BOOL)_isAbleToUpdateWithModel:(ZZGridDomainModel *)model
{
    if ([[self.videoPlayer playedFriendModel].idTbm isEqualToString:model.relatedUser.idTbm])
    {
        return NO;
    }

    return YES;
}

#pragma mark - Output

- (void)updateFriendThatPrevouslyWasOnGridWithModel:(ZZFriendDomainModel *)model
{
    [self _handleSentWelcomeHintWithFriendDomainModel:model];
}

- (void)updateDownloadProgress:(CGFloat)progress forModel:(ZZFriendDomainModel *)friendModel
{

    [self.userInterface updateDownloadingProgressTo:progress forModel:friendModel];
}


#pragma mark - EVENT InviteHint

- (void)dataLoadedWithArray:(NSArray *)data
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupWithModels:data];
        [self _handleInviteEvent];

        BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
        BOOL isSwitchCameraAvailable = [ZZGridActionStoredSettings shared].switchCameraFeatureEnabled;

        [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:
                isTwoCamerasAvailable && isSwitchCameraAvailable];

        [self _showRecordWelcomeIfNeededWithData:data];
    });
}

- (void)updateSwithCameraFeatureIsEnabled:(BOOL)isEnabled
{
    BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:(isTwoCamerasAvailable && isEnabled)];
}

- (void)_showRecordWelcomeIfNeededWithData:(NSArray *)data
{
    if ([ZZFriendDataProvider friendsOnGrid].count == 1)
    {
        CGFloat kDelayAfterViewLoaded = 1.5f;
        ANDispatchBlockAfter(kDelayAfterViewLoaded, ^{
            NSInteger indexWhenOneFriendOnGrid = 5;
            ZZFriendDomainModel *model = [[ZZFriendDataProvider friendsOnGrid] firstObject];
            [self.actionHandler handleEvent:ZZGridActionEventTypeGridLoaded withIndex:indexWhenOneFriendOnGrid friendModel:model];
        });
    }
}

- (void)dataLoadingDidFailWithError:(NSError *)error
{
    //TODO: error
}


- (void)gridAlreadyContainsFriend:(ZZGridDomainModel *)model
{
    [ZZGridAlertBuilder showAlreadyConnectedDialogForUser:model.relatedUser.firstName completion:^{
//        model.isDownloadAnimationViewed = YES;
        [self.dataSource updateCellWithModel:model];
        [self.userInterface showFriendAnimationWithFriendModel:model.relatedUser];
    }];
}

- (void)showAlreadyContainFriend:(ZZFriendDomainModel *)friendModel compeltion:(ANCodeBlock)completion
{
    [ZZGridAlertBuilder showAlreadyConnectedDialogForUser:friendModel.firstName completion:^{
        if (completion)
        {
            completion();
        }
    }];
}

- (void)userHasNoValidNumbers:(ZZContactDomainModel *)model;
{
    [self showNoValidPhonesDialogFromModel:model];
}

- (void)userNeedsToPickPrimaryPhone:(ZZContactDomainModel *)contact
{
    [self showChooseNumberDialogForUser:contact];
}

- (void)userHasNoAppInstalled:(ZZContactDomainModel *)contact
{
    [self _showSendInvitationDialogForUser:contact];
}

- (void)friendRecievedFromServer:(ZZFriendDomainModel *)friendModel
{
    if (friendModel.hasApp)
    {
        [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
    }
    else
    {
        [self _showInvitationFormForModel:friendModel
                                  isNudge:NO
                         invitationMethod:self.userSelectedInviteType];
    }
}

- (void)loadingStateUpdatedTo:(BOOL)isLoading
{
    [self.userInterface updateLoadingStateTo:isLoading];
}

- (NSInteger)indexOnGridViewForFriendModel:(ZZFriendDomainModel *)model
{
    return [self.userInterface indexOfFriendModelOnGridView:model];
}

- (NSInteger)indexOfBottomMiddleCell
{
    return [self.userInterface indexOfBottomMiddleCell];;
}

#pragma mark - Module Interface

- (void)presentMenu
{
    if (![[ZZVideoRecorder shared] isRecording])
    {
        [self.actionHandler hideHint];
        self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabContacts;
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

- (UIView *)presentedView
{
    return self.wireframe.mainWireframe.moduleInterface.overlayView;
}

- (CGRect)frameOfViewForFriendModelWithID:(NSString *)friendID
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    NSUInteger index = [self.dataSource indexForFriendDomainModel:friendModel];
    
    if (index == NSNotFound)
    {
        return CGRectZero;
    }
    
    ZZGridCellViewModel *cellModel = [self.dataSource viewModelAtIndex:index];
    
    UIView *view = cellModel.playerContainerView;
    
    return [view convertRect:view.frame toView:view.window];
}

- (void)didTapOverflowMenuItem:(MenuItem *)item atFriendModelWithID:(NSString *)friendID
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    if (item.type == MenuItemTypeConvertToText)
    {
        [self.wireframe presentTranscriptionForUserWithID:friendID];
        return;
    }
    
    if (item.type == MenuItemTypeSendText)
    {
        ANCodeBlock block = ^{
            [self.wireframe presentComposeForUserWithID:friendID];
        };
        
        if (friendModel.abilities & ZZFriendAbilitiesMessaging)
        {
            block();
        }
        else
        {
            [self _showNoMessagingFeatureDialog:friendModel confirmation:block];
        }
        return;
    }
    
    if (item.type == MenuItemTypePlayFullscreen)
    {
        [self.videoPlayer playVideoForFriend:friendModel];
        [self.videoPlayer showFullscreen];
        return;
    }
    
}

- (void)playVideosIfNoDownloadsForUser:(NSString *)mKey
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithMKeyValue:mKey];
    
    if (friendModel == nil)
    {
        return;
    }
    
    if (friendModel.hasDownloadingVideo)
    {
        return;
    }
    
    NSUInteger index = [self.dataSource indexForFriendDomainModel:friendModel];
    
    if (index == NSNotFound)
    {
        return;
    }
    
    [self.videoPlayer playVideoForFriend:friendModel];
}

#pragma mark - DataSource Delegate

- (void)showHint
{
    if ([ZZFriendDataProvider friendsCount] == 0)
    {
        return;
    }

    NSString *msg;

    if ([ZZVideoDataProvider countVideosWithStatus:ZZVideoIncomingStatusDownloaded] > 0)
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

- (void)_showToastWithMessage:(NSString *)message
{
    [[iToast makeText:message] show];
}

- (BOOL)_isNetworkEnabled
{
    return [self.reachability isReachable];
}

#pragma mark - ZZPlayerModuleDelegate

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];
    
    [self.userInterface setBadgesHidden:YES forFriendModel:friendModel];
    [self.userInterface updateRotatingEnabled:NO];
}

- (void)videoPlayerDidFinishPlayingWithModel:(ZZFriendDomainModel *)friendModel
{
    [self.interactor updateFriendAfterVideoStopped:friendModel];
    [self _handleRecordHintWithCellViewModel:friendModel];
    [self.userInterface setBadgesHidden:NO forFriendModel:friendModel];
    [self.userInterface updateRotatingEnabled:YES];
}

#pragma mark - ZZGridDataSourceDelegate

- (void)switchCamera
{    
    [self.userInterface prepareForCameraSwitchAnimation];
    [[ZZVideoRecorder shared] switchCamera:^{
        [self.userInterface showCameraSwitchAnimation];
    }];
}

- (void)stopPlaying
{
    [self.videoPlayer stop];
}


#pragma mark - Menu Delegate

- (void)userSelectedOnMenu:(id)user
{
    if (![user isKindOfClass:[ZZFriendDomainModel class]])
    {
        [self.interactor addUserToGrid:user];
        return;
    }
    
    ZZFriendDomainModel *friendModel = user;
    
    if ([ZZGridDataProvider isRelatedUserOnGridWithID:friendModel.idTbm])
    {
        ZZLogDebug(@"Friend already in grid: %@", user);
        [self.userInterface showFriendAnimationWithFriendModel:friendModel];
    }
    else
    {
        [self.interactor addUserToGrid:user];
    }
}


#pragma mark - Invites

- (void)showNoValidPhonesDialogFromModel:(ZZContactDomainModel *)model
{
    [self _showNoValidPhonesDialogFromModel:model];
}

- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel *)contact
{
    [self _addingUserToGridDidFailWithError:error forUser:contact];
}

- (void)showChooseNumberDialogForUser:(ZZContactDomainModel *)user
{
    [self _showChooseNumberDialogForUser:user];
}

#pragma mark - TBMTableModalDelegate

- (void)updatePrimaryPhoneNumberForContact:(ZZContactDomainModel *)contact
{
    [self.interactor userSelectedPrimaryPhoneNumber:contact];
}


#pragma mark - Edit Friends

- (void)friendStateWasUpdated:(ZZFriendDomainModel *)model toVisible:(BOOL)isVisible
{
    [self.interactor friendWasUpdatedFromEditContacts:model toVisible:isVisible];
}


#pragma mark - Detail Screens

- (BOOL)isRecordingInProgress
{
    return [[ZZVideoRecorder shared] isRecording];
}


- (ZZSoundEffectPlayer *)soundPlayer
{
    if (!_soundPlayer)
    {
        _soundPlayer = [[ZZSoundEffectPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
    }
    return _soundPlayer;
}

#pragma mark - Action Handler Delegate

- (void)unlockedFeature:(ZZGridActionFeatureType)feature
{
    if (feature == ZZGridActionFeatureTypeSwitchCamera)
    {
        BOOL isTwoCamerasAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];

        [self.dataSource updateValueOnCenterCellWithHandleCameraRotation:
                (isTwoCamerasAvailable && [ZZGridActionStoredSettings shared].switchCameraFeatureEnabled)];
    }
    
    [[ZZSettingsManager sharedInstance] pushSettings];
}

- (NSInteger)friendsCountOnGrid
{
    return [self.dataSource friendsOnGridNumber];
}

- (void)showMenuTab
{
    self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabMenu;
}

- (void)showGridTab
{
    self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabGrid;
}

#pragma mark - Interactor Action Handler

- (void)handleModel:(ZZGridDomainModel *)model withEvent:(ZZGridActionEventType)event
{
    [self _handleEvent:event withDomainModel:model];
}

- (NSInteger)friendsNumberOnGrid
{
    return [self.dataSource friendsOnGridNumber];
}

- (ZZGridAlertBuilder *)alertBuilder
{
    if (!_alertBuilder)
    {
        _alertBuilder = [ZZGridAlertBuilder new];
    }

    return _alertBuilder;
}

#pragma mark - Two Finger Touch

- (void)_startTouchObserve
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [[window rac_signalForSelector:@selector(sendEvent:)]
            subscribeNext:^(RACTuple *touches) {
                for (id event in touches)
                {
                    NSSet *touches = [event allTouches];
                    [self _handleTouches:touches];
                };
            }];
    
}

- (void)_handleTouches:(NSSet *)touches
{
        UITouch *touch = [[touches allObjects] firstObject];
    
        BOOL recording = [ZZVideoRecorder shared].isRecording && ![ZZVideoRecorder shared].isCompleting;
    
        if (!recording)
        {
            return;
        }

        if ((touch.phase == UITouchPhaseBegan) ||
            (touch.phase == UITouchPhaseStationary))
        {
            ANDispatchBlockToMainQueue(^{
                [self _cancelRecordingWithDoubleTap];
            });

            return;
        }
        
}

- (void)_cancelRecordingWithDoubleTap
{
    [self cancelRecordingWithReason:NSLocalizedString(@"record-two-fingers-touch", nil)];
    ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
        [self _showToastWithMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
}

#pragma mark - ZZGridModelPresenterInterface

- (void)viewModelDidTapOverflowButton:(ZZGridCellViewModel *)viewModel
{
    if (self.videoPlayer.isPlayingVideo)
    {
        [self.videoPlayer stop];
        return;
    }
    
    if (self.isGridRotate)
    {
        return;
    }
    
    MenuItem *convertToText = [[MenuItem alloc] initWithType:MenuItemTypeConvertToText];
    MenuItem *playFullscreen = [[MenuItem alloc] initWithType:MenuItemTypePlayFullscreen];
    MenuItem *sendText = [[MenuItem alloc] initWithType:MenuItemTypeSendText];
    
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID: viewModel.item.relatedUser.idTbm];
    
    BOOL showFullscreenItem = friendModel.videos.count > 0 && [ZZGridActionStoredSettings shared].fullscreenFeatureEnabled;
    NSArray<MenuItem *> *items = showFullscreenItem ? @[convertToText, sendText, playFullscreen] : @[convertToText, sendText];
    
    if (![ZZThumbnailGenerator hasLastThumbForUser:friendModel])
    {
        items = @[sendText];
    }
    
    [self.userInterface showOverflowMenuWithItems:items forModel:viewModel.item.relatedUser];
}

- (BOOL)isGridRotate
{
    return [self.userInterface isGridRotating];
}

- (void)viewModelDidTapCell:(ZZGridCellViewModel *)viewModel
{
    if (self.userInterface.isGridRotating)
    {
        return;
    }
    
    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];
    [self.videoPlayer playVideoForFriend:viewModel.item.relatedUser];
}

- (void)addUserToItem:(ZZGridCellViewModel *)model
{
    [self presentMenu];
}

- (BOOL)isGridCellEnablePlayingVideo:(ZZGridCellViewModel *)model
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
            
            NSString *badConnectionTitle = NSLocalizedString(@"internet-connection-error-title", nil);
            NSString *message = NSLocalizedString(@"internet-connection-error-message", nil);
            NSString *actionButtonTitle = NSLocalizedString(@"internet-connection-error-button-title", nil);
            
            [ZZGridAlertBuilder showAlertWithTitle:badConnectionTitle
                                           message:message
                                 cancelButtonTitle:nil
                                actionButtonTitlte:actionButtonTitle action:^{
                                }];
            
        }
        else
        {
            isEnabled = YES;
        }
    }
    
    return isEnabled;

}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    [self.interactor updateLastActionForFriend:userModel];
    [self _nudgeUser:userModel];

}

      - (void)viewModel:(ZZGridCellViewModel *)viewModel
didChangeRecordingState:(BOOL)isRecording
             completion:(void (^)(BOOL isRecordingSuccess))completionBlock
{
    ZZLogInfo(@"recordingStateUpdatedToState:%d", isRecording);
    
    [self.interactor updateLastActionForFriend:viewModel.item.relatedUser];
    
    if (ANIsEmpty(viewModel.item.relatedUser.idTbm))
    {
        return;
    }
    
    if (isRecording)
    {
        [self.actionHandler hideHint];

        [self.videoPlayer stop];
        
        ANDispatchBlockToMainQueue(^{
            [self.videoPlayer stop];
            NSURL *url = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:viewModel.item.relatedUser.idTbm];
            [self.userInterface updateRecordViewStateTo:isRecording];
            
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
            [self.userInterface updateRecordViewStateTo:isRecording];
            
            [[ZZVideoRecorder shared] stopRecordingWithCompletionBlock:^(BOOL isRecordingSuccess) {
                if (isRecordingSuccess)
                {
                    [self _handleSentMessageEventWithCellViewModel:viewModel];
                }
                completionBlock(isRecordingSuccess);
            }];
        });
    }
    
    [self.userInterface updateRollingStateTo:!isRecording];
    
    // Show nudge dialog case: 
    
    ZZFriendDomainModel *friendModel = viewModel.item.relatedUser;
    
    if (isRecording || friendModel.hasApp || !friendModel.everSent)
    {
        return;
    }
    
    [self nudgeSelectedWithUserModel:friendModel];

}

- (void)cancelRecordingWithReason:(NSString *)reason
{
    [[ZZVideoRecorder shared] cancelRecordingWithReason:reason];
    [self.userInterface updateRecordViewStateTo:NO];

}

#pragma mark ComposeModuleDelegate

- (void)didSendMessageTo:(ZZFriendDomainModel *)friendModel
{
    [self.userInterface showSentAnimationWithFriendModel:friendModel];
}

@end

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
#import "TBMAlertController.h"
#import "iToast.h"
#import "ZZContactDomainModel.h"
#import "TBMPhoneUtils.h"
#import "ZZAPIRoutes.h"
#import "ZZGridAlertBuilder.h"
#import "ZZUserDataProvider.h"
#import "TBMEventsFlowModuleInterface.h"
#import "TBMEventsFlowModulePresenter.h"

@interface ZZGridPresenter () <ZZGridDataSourceDelegate, ZZVideoPlayerDelegate>

@property(nonatomic, strong) ZZGridDataSource* dataSource;
@property(nonatomic, strong) ZZSoundPlayer* soundPlayer;
@property(nonatomic, strong) ZZVideoPlayer* videoPlayer;

@end

@implementation ZZGridPresenter
//TODO: (EventsFlow) When sent                  [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidSend];
//TODO: (EventsFlow) When friend add            [self.eventsFlowModule throwEvent:TBMEventFlowEventFriendDidAddWithoutApp];
//TODO: (EventsFlow) When Message Received      [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidReceive];
//TODO: (EventsFlow) When
//TODO: (EventsFlow) Setup events flow module

- (void)configurePresenterWithUserInterface:(UIViewController <ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    self.dataSource.delegate = self;
    [self.userInterface updateWithDataSource:self.dataSource];

    self.videoPlayer = [ZZVideoPlayer new];
    self.videoPlayer.delegate = self;
    [self _setupNotifications];
    [self.interactor loadData];
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
}

- (id)eventsFlowModule
{
    if (!_eventsFlowModule)
    {
        TBMEventsFlowModulePresenter* eventsFlowModulePresenter = [TBMEventsFlowModulePresenter new];
        eventsFlowModulePresenter.gridModule = self;
        _eventsFlowModule = eventsFlowModulePresenter;
    }
    return _eventsFlowModule;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateGridData:(NSNotification*)notification
{
    TBMFriend* updatedFriend = notification.object;
    [self.dataSource updateModelWithFriend:updatedFriend];
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
    [self.dataSource setupWithModels:data];

    BOOL isSwitchCameraAvailable = [[ZZVideoRecorder shared] areBothCamerasAvailable];
    [self.dataSource setupCenterViewModelShouldHandleCameraRotation:isSwitchCameraAvailable];

    [[ZZVideoRecorder shared] updateRecordView:[self.dataSource centerViewModel].recordView];
}

- (void)dataLoadingDidFailWithError:(NSError*)error
{
    //TODO: error
}

- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel*)model
{
    [self.dataSource selectedViewModelUpdatedWithItem:model];
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

- (void)userHaSeveralValidNumbers:(NSArray*)phoneNumbers
{
    [self showChooseNumberDialogFromNumbersArray:phoneNumbers];
}

- (void)userHasNoAppInstalled:(NSString*)firsName
{
    [self showSendInvitationDialogForUser:firsName];
}

- (void)friendRecievedFromeServer:(ZZFriendDomainModel*)friendModel
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
    [self.dataSource updateStorageWithModel:model];
}

#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
    [self.userInterface menuWasOpened];
}

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model
{
    if ((ZZGridCenterCellViewModel*) model == [self.dataSource centerViewModel])
    {
        if ([TBMFriend count] == 0)
            return;

        NSString* msg;
        if ([TBMVideo downloadedUnviewedCount] > 0)
        {
            msg = @"Tap a friend to play.";
        }
        else
        {
            msg = @"Press and hold a friend to record.";

        [ZZGridAlertBuilder showHintalertWithMessage:msg];
    }
    else if (model.item.relatedUser)
    {
//        model.item.relatedUser.timeOfLastAction = [NSDate date]; //TODO:
//        [[TBMVideoPlayer sharedInstance] togglePlayWithIndex:[self indexWithView:view] frame:view.frame];
    }
    else
    {
        [self.interactor selectedPlusCellWithModel:model.item];
        [self presentMenu];
    }
}

- (UIView*)viewForDialog
{
    return [self.userInterface viewForDialogs];
}

- (CGRect)gridGetFrameForFriend:(NSUInteger)friendCellIndex inView:(UIView*)view
{
    NSIndexPath* friendIndexPath = [self _indexPathForFriendAtindex:friendCellIndex];
    return [self.userInterface gridGetFrameForIndexPath:friendIndexPath inView:view];
}

- (CGRect)gridGetCenterCellFrameInView:(UIView*)view
{
    return [self.userInterface gridGetCenterCellFrameInView:view];
}

- (CGRect)gridGetFrameForUnviewedBadgeForFriend:(NSUInteger)friendCellIndex inView:(UIView*)view
{
    NSIndexPath* friendIndexPath = [self _indexPathForFriendAtindex:friendCellIndex];
    return [self.userInterface gridGetUnviewedBadgeFrameForIndexPath:friendIndexPath inView:view];
}

- (NSUInteger)lastAddedFriendOnGridIndex
{
    return [self.interactor lastAddedFriendIndex];
}

- (NSString*)lastAddedFriendOnGridName
{
    return [self.interactor lastAddedFriendName];
}


#pragma mark - Video Player Delegate

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL
{
    //TODO: delete video file
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidStartPlaying];
}

- (void)videoPlayerURLWasFinishedPlaying:(NSURL*)videoURL
{
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidViewed];
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidStopPlaying];
}

#pragma mark - Data source delegate

- (void)nudgeSelectedWithUserModel:(ZZFriendDomainModel*)userModel
{
    [self.interactor updateLastActionForFriend:userModel];
    
    [ZZGridAlertBuilder showPreNudgeAlertWithFriendFirstName:userModel.firstName completion:^{
        [self showSmsDialogForModel:userModel];
    }];
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel // TODO: add states for gesture recognizer and show toasts
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
            NSURL* url = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:viewModel.item.relatedUser];
            [[ZZVideoRecorder shared] startRecordingWithVideoURL:url];
            model.isRecording = YES;
        }
        else
        {//OLD
//            TBMGridElement *ge = [self gridElementWithView:view];
//            if (ge.friend != nil) {
//                [[self videoRecorder] stopRecording];
//            }
            model.isRecording = NO;
            [[ZZVideoRecorder shared] stopRecording];
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
        [self.soundPlayer play];
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

#pragma mark - Module Delegate Method

- (void)selectedUser:(id)user
{
    [self.interactor selectedUserWithModel:user];
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
    [self.eventsFlowModule throwEvent:TBMEventFlowEventApplicationDidLaunch];
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

- (void)showChooseNumberDialogFromNumbersArray:(NSArray*)array// TODO: move to grid alerts
{
    //TODO: this alert is SUXX
    ANDispatchBlockToMainQueue(^{
        TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Attention"
                                                                         message:@"Choose phone number"];
        
        [array enumerateObjectsUsingBlock:^(NSString* phoneNumber, NSUInteger idx, BOOL *stop) {
            [alert addAction:[SDCAlertAction actionWithTitle:phoneNumber style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
                [self.interactor userSelectedPhoneNumber:phoneNumber];
            }]];
        }];
        
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleCancel handler:^(SDCAlertAction *action) {
        }]];

        [alert presentWithCompletion:nil];
    });
}

- (void)showSendInvitationDialogForUser:(NSString*)firsName
{
    [ZZGridAlertBuilder showSendInvitationDialogForUser:firsName completion:^
    {
        [self.interactor inviteUserThatHasNoAppInstalled];
    }];
}

- (void)showConnectedDialogForModel:(ZZFriendDomainModel*)friend
{
    [self.interactor updateLastActionForFriend:friend];
    
    [ZZGridAlertBuilder showConnectedDialogForUser:friend.firstName completion:^{
        [self.interactor addNewFriendToGridModelsArray];
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

@end

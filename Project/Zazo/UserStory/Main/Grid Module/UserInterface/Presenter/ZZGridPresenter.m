//
//  ZZGridPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZVideoRecorder.h"
#import "ZZVideoUtils.h"
#import "ZZSoundPlayer.h"
#import "ZZVideoPlayer.h"
#import "TBMFriend.h"
#import "TBMAlertController.h"
#import "iToast.h"
#import "ZZContactDomainModel.h"
#import "TBMTableModal.h"

@interface ZZGridPresenter () <ZZGridDataSourceDelegate, ZZVideoPlayerDelegate, TBMTableModalDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZSoundPlayer* soundPlayer;
@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    self.dataSource.delegate = self;
    [self.userInterface updateWithDataSource:self.dataSource];
    
    self.videoPlayer = [ZZVideoPlayer new];
    self.videoPlayer.delegate = self;
    
    [self.interactor loadData];
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

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model
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
    [self.userInterface showFriendAnimationWithModel:friendModel];
}

- (void)userHasNoValidNumbers:(ZZContactDomainModel*)model;
{
    [self showNoValidPhonesDialogFromModel:model];
}

- (void)userHaSeveralValidNumbers:(NSArray*)phoneNumbers
{
    [self showChooseNumberDialogFromNumbersArray:phoneNumbers];
}

#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
    [self.userInterface menuWasOpened];
}

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model
{
    if ((ZZGridCenterCellViewModel*)model == [self.dataSource centerViewModel])
    {
        if ([TBMFriend count] == 0)
            return;
        
        NSString *msg;
        if ([TBMVideo downloadedUnviewedCount] > 0)
            msg = @"Tap a friend to play.";
        else
            msg = @"Press and hold a friend to record.";
        
        TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Hint" message:msg];
        [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
        [alert presentWithCompletion:nil];
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


#pragma mark - Video Player Delegate

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL
{
    //TODO: delete video file
}

- (void)videoPlayerURLWasFinishedPlaying:(NSURL*)videoURL
{
    // nothing ...
}

#pragma mark - Data source delegate

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    //TODO:
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel
{
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


#pragma mark - Private

//TODO:
- (void)toastNotSent
{
    [[iToast makeText:@"Not sent"] show];
}

- (void)showNoValidPhonesDialogFromModel:(ZZContactDomainModel*)model
{
    NSString *title = @"No Mobile Number";
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts, kill %@, then try again.", [model fullName], model.firstName, appName];
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void)showChooseNumberDialogFromNumbersArray:(NSArray*)array
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

//TableModalDelegate methods
- (void)didSelectRow:(NSInteger)index
{
    
}

@end

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

@interface ZZGridPresenter () <ZZGridCellViewModelDelegate, ZZGridDataSourceDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZSoundPlayer* soundPlayer;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    
    self.dataSource.delegate = self;
    [self.userInterface updateWithDataSource:self.dataSource];
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


#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
    [self.userInterface menuWasOpened];
}

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model
{
    if (model)
    {
        [self.interactor selectedPlusCellWithModel:model.item];
        [self presentMenu];
    }
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    //TODO:
}

- (void)recordingStateUpdateWithView:(UIView *)view toState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel
{
    ZZGridCenterCellViewModel* model = [self.dataSource centerViewModel];
    if (isEnabled && view)
    {
        
        if (viewModel.item.relatedUser && viewModel.item.relatedUser.idTbm)
        {
            NSURL* url = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:viewModel.item.relatedUser];
            [[ZZVideoRecorder shared] startRecordingWithVideoURL:url];
            model.isRecording = YES;
        }
    }
    
    [self.userInterface updateRollingStateTo:!isEnabled];
    [self.soundPlayer play];
   
    if (isEnabled)
    {
        
    }
    else
    {
        model.isRecording = NO;
        [[ZZVideoRecorder shared] stopRecording];
    }
    [self.dataSource reloadCenterCell];
}


//- (void)startRecordingWithGridCell:(ZZGridCollectionCell*)gridCell
//{
//    ZZGridCellViewModel* model = [gridCell model];
//    if (model.item.relatedUser && model.item.relatedUser.idTbm)
//    {
//        [self.gridCell hideChangeCameraButton];
//        self.recordVideoUrl = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:model.item.relatedUser];
//        [self startRecordingWithVideoUrl:self.recordVideoUrl];
//        [self.recorder.session removeAllSegments];
//        [self.recorder record];
//    }
//    [self.gridCell showRecordingOverlay];
//}
//


- (ZZGridCenterCell*)centerCell
{
    NSIndexPath* centerCellIndex = [NSIndexPath indexPathForRow:[self.interactor centerCellIndex] inSection:0];
    id centerCell = [self.userInterface cellAtIndexPath:centerCellIndex];

    return centerCell;
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

@end

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
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridCenterCell.h"
#import "ZZGridCollectionCell.h"
#import "ZZVideoUtils.h"
#import "ZZGridCellViewModel.h"
#import "ZZSoundPlayer.h"

@interface ZZGridPresenter () <ZZGridCellViewModellDelegate, ZZGridDataSourceDelegate>

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

- (void)recordingStateUpdateWithView:(UIView *)view toState:(BOOL)isEnabled
{
    if (isEnabled && view)
    {
        [[ZZVideoRecorder shared] startRecordingWithGridCell:view];
    }
    
    [self.userInterface updateRollingStateTo:!isEnabled];
    [self.soundPlayer play];
    if (isEnabled)
    {
        
        [[self centerCell] showRecordingOverlay];
    }
    else
    {
        [[self centerCell] hideRecordingOverlay];
        [[ZZVideoRecorder shared] stopRecording];
    }
}

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

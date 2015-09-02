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
#import "ZZGridCollectionCellViewModel.h"



@interface ZZGridPresenter () <ZZGridCellViewModellDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    [self.userInterface udpateWithDataSource:self.dataSource];
    [self.interactor loadData];
}


- (void)presentEditFriends
{
    [self.wireframe closeMenu];
    [self.wireframe presentEditFriends];
}

- (void)presentSendEmail
{
    [self.interactor loadFeedbackModel];
   
}

#pragma mark - Output

- (void)loadedFeedbackDomainModel:(ANMessageDomainModel *)model
{
    [self.wireframe presentSendFeedbackWithFeedbackModel:model];
}

- (void)dataLoadedWithArray:(NSArray *)data
{
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isMemberOfClass:[ZZGridCollectionCellViewModel class]])
        {
            ZZGridCollectionCellViewModel* gridViewModel = (ZZGridCollectionCellViewModel*)obj;
            gridViewModel.delegate = self;
        }
    }];
    
    [self.dataSource.storage addItems:data];
}

- (void)dataLoadedWithError:(NSError *)error
{


}

- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel *)model
{
    [self.dataSource updateModel:model];
}

- (void)gridContainedFriend:(ZZFriendDomainModel *)friendModel
{
    [self.wireframe closeMenu];
    [self.userInterface showFriendAnimationWithModel:friendModel];
    
}

#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
    [self.userInterface menuIsOpened];
}

- (void)selectedCollectionViewWithModel:(ZZGridCollectionCellViewModel *)model
{
    if (model)
    {
        [self.interactor selectedPlusCellWithModel:model];
        [self presentMenu];
    }
}


#pragma mark - Collection Cell View Module Delegate

- (void)startRecordingWithView:(id)view
{
    [self.userInterface disableRolling];
    [self.userInterface playSound];
    [[self centerCell] showRecordingOverlay];
    [[ZZVideoRecorder sharedInstance] startRecordingWithGridCell:view];
}

- (void)stopRecording
{
    [self.userInterface playSound];
    [self.userInterface enableRolling];
    [[self centerCell] hideRecordingOverlay];
    [[ZZVideoRecorder sharedInstance] stopRecording];
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{

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


@end

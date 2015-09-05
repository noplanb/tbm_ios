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

static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridPresenter () <ZZGridCellViewModellDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZGridCellViewModel* selectedCellViewModel;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    [self.userInterface udpateWithDataSource:self.dataSource];
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

- (void)loadedFeedbackDomainModel:(ANMessageDomainModel *)model
{
    [self.wireframe presentSendFeedbackWithModel:model];
}

- (void)dataLoadedWithArray:(NSArray*)data
{
    NSArray* dataArray = [self viewModelFromGridDomainModels:data];
    [self.dataSource.storage addItems:dataArray];
}

- (void)dataLoadingDidFailWithError:(NSError*)error
{
    
}


- (NSArray*)viewModelFromGridDomainModels:(NSArray *)itemsArray
{
    __block NSMutableArray* viewModels = [NSMutableArray array];

    [itemsArray enumerateObjectsUsingBlock:^(ZZGridDomainModel* item, NSUInteger idx, BOOL *stop) {
        id model;
        
        if (idx == kGridCenterCellIndex)
        {
            model = [ZZGridCenterCellViewModel new];
        }
        else
        {
            model = [ZZGridCellViewModel new];
            ZZGridCellViewModel* gridCell = model;
            gridCell.item = item;
            gridCell.delegate = self;
        }
        
        [viewModels addObject:model];
    }];
    
    return viewModels;
}

- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel *)model
{
    self.selectedCellViewModel.item = model;
    [self.dataSource reloadModel:self.selectedCellViewModel];
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

- (void)itemSelectedWithModel:(ZZGridCellViewModel *)model
{
    if (model)
    {
        self.selectedCellViewModel = model;
        [self.interactor selectedPlusCellWithModel:model.item];
        [self presentMenu];
    }
}


#pragma mark - Collection Cell View Module Delegate

- (void)startRecordingWithView:(id)view
{
    [self.userInterface disableRolling];
    [self.userInterface playSound];
    [[self centerCell] showRecordingOverlay];
    [[ZZVideoRecorder shared] startRecordingWithGridCell:view];
}

- (void)stopRecording
{
    [self.userInterface playSound];
    [self.userInterface enableRolling];
    [[self centerCell] hideRecordingOverlay];
    [[ZZVideoRecorder shared] stopRecording];
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

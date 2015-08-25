//
//  ZZGridPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZVideoRecorder.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCenterCell.h"
#import "ZZGridCollectionCell.h"
#import "ZZVideoUtils.h"


@interface ZZGridPresenter () <ZZGridDomainModelDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;
@property (nonatomic, strong) ZZVideoRecorder* videoRecorder;

@end

@implementation ZZGridPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface
{
    self.videoRecorder = [ZZVideoRecorder new];
    self.userInterface = userInterface;
    self.dataSource = [ZZGridDataSource new];
    [self.userInterface udpateWithDataSource:self.dataSource];
    [self.interactor loadData];
}

#pragma mark - Output

- (void)dataLoadedWithArray:(NSArray *)data
{
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isMemberOfClass:[ZZGridCenterCellViewModel class]])
        {
            ZZGridCenterCellViewModel* center = (ZZGridCenterCellViewModel*)obj;
            center.videoRecorder = self.videoRecorder;
        }
        if ([obj isMemberOfClass:[ZZGridDomainModel class]])
        {
            ZZGridDomainModel* gridModel = (ZZGridDomainModel*)obj;
            gridModel.delegate = self;
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

#pragma mark - Module Interface

- (void)presentMenu
{
    [self.wireframe toggleMenu];
}

- (void)selectedCollectionViewWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.interactor centerCellIndex])
    {
        [self.interactor selectedPlusCellWithIndexPath:indexPath];
        [self presentMenu];
    }
}

#pragma mark - Collection Cell View Module Delegate

- (void)startRecordingWithView:(id)view
{
    [[self centerCell] showRecordingOverlay];
    [self.videoRecorder startRecordingWithGridCell:view];
}

- (void)stopRecording
{
    [[self centerCell] hideRecordingOverlay];
    [self.videoRecorder stopRecording];
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

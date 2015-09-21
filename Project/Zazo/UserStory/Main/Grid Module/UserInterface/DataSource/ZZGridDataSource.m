//
//  ZZGridDataSource.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZGridCellViewModel.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZFriendDomainModel.h"
#import "TBMFriend.h"
#import "ZZFriendDataProvider.h"

static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridDataSource () <ZZGridCellViewModelDelegate, ZZGridCenterCellViewModelDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* selectedCellViewModel;

@end

@implementation ZZGridDataSource

- (instancetype)init
{
    if (self = [super init])
    {
        self.storage = [ANMemoryStorage new];
    }
    return self;
}

- (void)reloadStorage
{
//    [self.storage.delegate storageNeedsReload];
}

- (void)updateDataSourceWithGridModelFromNotification:(ZZGridDomainModel*)gridModel
{   
    if (!ANIsEmpty(gridModel))
    {
        ANSectionModel* section = [self.storage.sections firstObject];
        NSArray* cellModels = section.objects;
        __block ZZGridCellViewModel* cellModel;
        [cellModels enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
            if ([model isKindOfClass:[ZZGridCellViewModel class]])
            {
                cellModel = model;
                if ([cellModel.item.index isEqualToNumber:gridModel.index])
                {
                    cellModel.item = gridModel;
                    cellModel.hasUploadedVideo = [gridModel.relatedUser hasIncomingVideo];
                    
                    cellModel.isUploadedVideoViewed = (gridModel.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
                    
                    if (gridModel.relatedUser.unviewedCount > 0)
                    {
                        cellModel.badgeNumber = @(gridModel.relatedUser.unviewedCount);
                    }
                    
                    [self.storage reloadItem:cellModel];
                    *stop = YES;
                }
            }
        }];
    }
}

- (void)setupWithModels:(NSArray *)models
{
    models = [[models.rac_sequence map:^id(ZZGridDomainModel* value) {
        
        ZZGridCellViewModel* viewModel = [ZZGridCellViewModel new];
        viewModel.item = value;
        viewModel.delegate = self;
        
        viewModel.hasUploadedVideo = [value.relatedUser hasIncomingVideo];
        viewModel.isUploadedVideoViewed = (value.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
        
        if (value.relatedUser.unviewedCount > 0)
        {
            viewModel.badgeNumber = @(value.relatedUser.unviewedCount);
        }

        return viewModel;
    }] array];
    
    [self.storage addItems:models];
}

- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model
{
    self.selectedCellViewModel.item = model;
    [self.storage reloadItem:self.selectedCellViewModel];
    
    self.selectedCellViewModel = nil;
}

- (void)updateStorageWithModel:(ZZGridDomainModel*)model
{
    
    NSArray *allItems = [self.storage itemsInSection:0];
    [allItems enumerateObjectsUsingBlock:^(ZZGridCellViewModel *viewModel, NSUInteger idx, BOOL *stop) {
        if (![viewModel isKindOfClass:[ZZGridCenterCellViewModel class]])
        {
            if ([viewModel.item.index isEqual:model.index])
            {
                viewModel.item = model;
                [self.storage reloadItem:viewModel];
            }
        }
    }];
}

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedCellViewModel = [self.storage objectAtIndexPath:indexPath];
    [self.delegate itemSelectedWithModel:self.selectedCellViewModel];
}

- (void)setupCenterViewModelShouldHandleCameraRotation:(BOOL)shouldHandleRotation
{
    ZZGridCenterCellViewModel* model = [ZZGridCenterCellViewModel new];
    model.isChangeButtonAvailable = shouldHandleRotation;
    model.delegate = self;
    [self.storage addItem:model atIndexPath:[self _centerCellIndexPath]];
}

- (ZZGridCenterCellViewModel*)centerViewModel
{
    return [self.storage objectAtIndexPath:[self _centerCellIndexPath]];
}
- (void)updateCenterCellWithModel:(ZZGridCenterCellViewModel*)model
{
    [self.storage reloadItem:model];
}

#pragma mark - ViewModel Delegate

- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel *)viewModel
{
    [self.delegate recordingStateUpdatedToState:isEnabled viewModel:viewModel];
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    [self.delegate nudgeSelectedWithUserModel:userModel];
}

- (void)playingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel
{
    [self.delegate toggleVideoWithViewModel:viewModel toState:isEnabled];
}

- (void)switchCamera
{
    [self.delegate switchCamera];
}


#pragma mark - Private

- (NSIndexPath*)_centerCellIndexPath
{
    return [NSIndexPath indexPathForItem:kGridCenterCellIndex inSection:0];
}

@end


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

@interface ZZGridDataSource ()
<
ZZGridCellViewModelDelegate,
ZZGridCenterCellViewModelDelegate
>

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
    ANDispatchBlockToMainQueue(^{
       [self.storage.delegate storageNeedsReload];
    });
}

- (void)updateDataSourceWithGridModelFromNotification:(ZZGridDomainModel*)gridModel
                                  withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock
{
    if (!ANIsEmpty(gridModel))
    {
        ANSectionModel* section = [self.storage.sections firstObject];
        NSArray* cellModels = [section.objects copy];
        __block ZZGridCellViewModel* cellModel;
        [cellModels enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
            if ([model isKindOfClass:[ZZGridCellViewModel class]])
            {
                cellModel = model;
                if ([cellModel.item.index isEqualToNumber:gridModel.index])
                {
                    cellModel.item = gridModel;
                    
                    cellModel.hasDownloadedVideo = [gridModel.relatedUser hasIncomingVideo];
                    cellModel.hasUploadedVideo = [gridModel.relatedUser hasOutgoingVideo];//[gridModel.relatedUser hasIncomingVideo];
                    
                    cellModel.isUploadedVideoViewed = (gridModel.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
                    
                    
                    if (gridModel.relatedUser.unviewedCount > 0)
                    {
                        cellModel.badgeNumber = @(gridModel.relatedUser.unviewedCount);
                    }
                    
                    ANDispatchBlockToMainQueue(^{
                        [self.storage reloadItem:cellModel];
                        if (![cellModel.prevBadgeNumber isEqualToNumber:cellModel.badgeNumber])
                        {
                            if (completionBlock)
                            {
                                completionBlock(YES);
                            }
                            cellModel.prevBadgeNumber = cellModel.badgeNumber;
                        }
                    });
                    *stop = YES;
                }
            }
        }];
    }
}

- (void)updateDataSourceWithDownloadAnimationWithGridModel:(ZZGridDomainModel*)gridModel
                                  withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock
{
    if (!ANIsEmpty(gridModel))
    {
        ANSectionModel* section = [self.storage.sections firstObject];
        NSArray* cellModels = [section.objects copy];
        __block ZZGridCellViewModel* cellModel;
        [cellModels enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
            if ([model isKindOfClass:[ZZGridCellViewModel class]])
            {
                cellModel = model;
                if ([cellModel.item.index isEqualToNumber:gridModel.index])
                {
                    cellModel.isNeedToShowDownloadAnimation = YES;
                    
                    ANDispatchBlockToMainQueue(^{
                        [self.storage reloadItem:cellModel];
                        if (completionBlock)
                        {
                            completionBlock(YES);
                        }
                    });
                    *stop = YES;
                }
            }
        }];
    }
}

- (void)setupWithModels:(NSArray *)models completion:(ANCodeBlock)completion
{
    models = [[models.rac_sequence map:^id(ZZGridDomainModel* value) {
        
        ZZGridCellViewModel* viewModel = [ZZGridCellViewModel new];
        viewModel.item = value;
        viewModel.delegate = self;
        viewModel.hasDownloadedVideo = [value.relatedUser hasIncomingVideo];
        viewModel.hasUploadedVideo = [value.relatedUser hasOutgoingVideo];//[value.relatedUser hasIncomingVideo];
        viewModel.isUploadedVideoViewed = (value.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
        
        if (value.relatedUser.unviewedCount > 0)
        {
            viewModel.prevBadgeNumber = @(value.relatedUser.unviewedCount);
            viewModel.badgeNumber = @(value.relatedUser.unviewedCount);
        }

        return viewModel;
    }] array];
    
    ANDispatchBlockToMainQueue(^{
       [self.storage addItems:models];
        if (completion)
        {
            completion();
        }
    });
}

- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model
{
    self.selectedCellViewModel.item = model;
    ANDispatchBlockToMainQueue(^{
        [self.storage reloadItem:self.selectedCellViewModel];
    });
    
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
                ANDispatchBlockToMainQueue(^{
                   [self.storage reloadItem:viewModel];
                });
            }
        }
    }];
}

- (void)updateModel:(ZZGridDomainModel*)model
{
    NSArray *allItems = [self.storage itemsInSection:0];
    
    [allItems enumerateObjectsUsingBlock:^(ZZGridCellViewModel *viewModel, NSUInteger idx, BOOL *stop) {
        if (![viewModel isKindOfClass:[ZZGridCenterCellViewModel class]])
        {
            if ([viewModel.item.relatedUser.mKey isEqualToString:model.relatedUser.mKey])
            {
                
                
                
                viewModel.item = model;
                
                viewModel.hasDownloadedVideo = [model.relatedUser hasIncomingVideo];
                viewModel.hasUploadedVideo = [model.relatedUser hasOutgoingVideo];//[gridModel.relatedUser hasIncomingVideo];
                viewModel.isUploadedVideoViewed = (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
                
                
             
                viewModel.badgeNumber = @(model.relatedUser.unviewedCount);
                
                
                ANDispatchBlockToMainQueue(^{
                    [self.storage reloadItem:viewModel];
                });
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
    ANDispatchBlockToMainQueue(^{
        [self.storage addItem:model atIndexPath:[self _centerCellIndexPath]];
    });
}

- (ZZGridCenterCellViewModel*)centerViewModel
{
    return [self.storage objectAtIndexPath:[self _centerCellIndexPath]];
}
- (void)updateCenterCellWithModel:(ZZGridCenterCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
       [self.storage reloadItem:model];
    });
}

#pragma mark - ViewModel Delegate

- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel *)viewModel withCompletionBlock:(void (^)(BOOL))completionBlock
{
    [self.delegate recordingStateUpdatedToState:isEnabled viewModel:viewModel withCompletionBlock:completionBlock];
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    [self.delegate nudgeSelectedWithUserModel:userModel];
}

- (void)playingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel
{
    [self.delegate toggleVideoWithViewModel:viewModel toState:isEnabled];
}


#pragma mark - Center Cell Delegate

- (void)switchCamera
{
    [self.delegate switchCamera];
}

- (void)showHint
{
    [self.delegate showHint];
}

- (BOOL)isVideoPalying
{
    return [self.delegate isVideoPlaying];
}


#pragma mark - Private

- (NSIndexPath*)_centerCellIndexPath
{
    return [NSIndexPath indexPathForItem:kGridCenterCellIndex inSection:0];
}

@end

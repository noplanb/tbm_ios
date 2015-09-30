
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
#import "ANMemoryStorage+UpdateWithoutAnimations.h"

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

//- (void)reloadDebugStatuses
//{
////    NSArray* objects = [[self.storage sectionAtIndex:0] objects];
////    
////    [objects enumerateObjectsUsingBlock:^(ZZGridCellViewModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////        
////        if ([obj isKindOfClass:[ZZGridCellViewModel class]])
////        {
////            [obj reloadDebugVideoStatus];
////        }
////    }];
//    [self.storage.delegate storageNeedsReload];
//}

- (void)updateDataSourceWithGridModelFromNotification:(ZZGridDomainModel*)gridModel
                                  withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock
{
    [self reloadStorage];
//    if (!ANIsEmpty(gridModel))
//    {
//        ANSectionModel* section = [self.storage.sections firstObject];
//        NSArray* cellModels = [section.objects copy];
//        __block ZZGridCellViewModel* cellModel;
//        [cellModels enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
//            if ([model isKindOfClass:[ZZGridCellViewModel class]])
//            {
//                cellModel = model;
//                if (cellModel.item.index == gridModel.index)
//                {
//                    cellModel.item = gridModel;
//                    
//                    cellModel.hasDownloadedVideo = [gridModel.relatedUser hasIncomingVideo];
//                    cellModel.hasUploadedVideo = [gridModel.relatedUser hasOutgoingVideo];//[gridModel.relatedUser hasIncomingVideo];
//                    
//                    cellModel.isUploadedVideoViewed = (gridModel.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
//                    
//                    
//                    if (gridModel.relatedUser.unviewedCount > 0)
//                    {
//                        cellModel.badgeNumber = @(gridModel.relatedUser.unviewedCount);
//                    }
//                    
//                    ANDispatchBlockToMainQueue(^{
//                        [self.storage reloadItem:cellModel];
//                        if (![cellModel.prevBadgeNumber isEqualToNumber:cellModel.badgeNumber])
//                        {
//                            if (completionBlock)
//                            {
//                                completionBlock(YES);
//                            }
//                            cellModel.prevBadgeNumber = cellModel.badgeNumber;
//                        }
//                    });
//                    *stop = YES;
//                }
//            }
//        }];
//    }
}

- (void)updateDataSourceWithDownloadAnimationWithGridModel:(ZZGridDomainModel*)gridModel
                                  withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock
{
    [self reloadStorage];
//    if (!ANIsEmpty(gridModel))
//    {
//        ANSectionModel* section = [self.storage.sections firstObject];
//        NSArray* cellModels = [section.objects copy];
//        __block ZZGridCellViewModel* cellModel;
//        [cellModels enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
//            if ([model isKindOfClass:[ZZGridCellViewModel class]])
//            {
//                cellModel = model;
//                if (cellModel.item.index == gridModel.index)
//                {
//                    cellModel.isNeedToShowDownloadAnimation = YES;
//                    
//                    ANDispatchBlockToMainQueue(^{
//                        [self.storage reloadItem:cellModel];
//                        if (completionBlock)
//                        {
//                            completionBlock(YES);
//                        }
//                    });
//                    *stop = YES;
//                }
//            }
//        }];
//    }
}

- (void)setupWithModels:(NSArray*)models
{
    __block ZZGridCenterCellViewModel* center = nil;
    
    ANSectionModel* sectionModel = [self.storage sectionAtIndex:0];
    NSArray* objects = [sectionModel.objects copy];
    NSMutableArray* updatedSection = [NSMutableArray arrayWithArray:sectionModel.objects ? : @[]];
    
    if (updatedSection.count)
    {
        [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ZZGridCenterCellViewModel class]])
            {
                center = obj;
            }
            [updatedSection removeObject:obj];
        }];
    }
    
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
    
    [updatedSection addObjectsFromArray:models];

    if (center)
    {
        [updatedSection insertObject:center atIndex:kGridCenterCellIndex];
    }
    ANSectionModel* updatedSectionModel = [self.storage sectionAtIndex:0 createIfNeeded:YES];
    [updatedSectionModel.objects removeAllObjects];
    [updatedSectionModel.objects addObjectsFromArray:updatedSection];
    [self.storage.delegate storageNeedsReload];
}

//- (void)reloadStorageWithModels:(NSArray*)models
//{
//    __block ZZGridCenterCellViewModel* center = nil;
//    
//    ANSectionModel* sectionModel = [self.storage sectionAtIndex:0];
//    NSMutableArray* objects = [sectionModel.objects mutableCopy];
//    NSMutableArray* updatedSection = [NSMutableArray arrayWithArray:sectionModel.objects ? : @[]];
//    
//    if (updatedSection.count)
//    {
//        
//        [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [models enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isKindOfClass:[ZZGridCellViewModel class]])
//                {
//                    ZZGridCellViewModel* cellViewModel = (ZZGridCellViewModel*)obj;
//                    if (cellViewModel.item.index == model.index)
//                    {
//                        cellViewModel.item = model;
//                        cellViewModel.delegate = self;
//                        cellViewModel.item.relatedUser = model.relatedUser;
//                        
//                        cellViewModel.hasDownloadedVideo = [model.relatedUser hasIncomingVideo];
//                        cellViewModel.hasUploadedVideo = [model.relatedUser hasOutgoingVideo];//[value.relatedUser hasIncomingVideo];
//                        cellViewModel.isUploadedVideoViewed = (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
//                        
//                        if (model.relatedUser.unviewedCount > 0)
//                        {
//                            cellViewModel.prevBadgeNumber = @(model.relatedUser.unviewedCount);
//                            cellViewModel.badgeNumber = @(model.relatedUser.unviewedCount);
//                        }
//                    }
//                }
//                else if ([obj isKindOfClass:[ZZGridCenterCellViewModel class]])
//                {
//                    center = obj;
//                }
//            }];
//        }];
//        
//        [updatedSection removeAllObjects];
//        
//        [objects removeObject:center];
//        
//        [updatedSection addObjectsFromArray:objects];
//        [updatedSection insertObject:center atIndex:kGridCenterCellIndex];
//        
//        ANSectionModel* updatedSectionModel = [self.storage sectionAtIndex:0 createIfNeeded:YES];
//        [updatedSectionModel.objects removeAllObjects];
//        [updatedSectionModel.objects addObjectsFromArray:updatedSection];
//        [self.storage.delegate storageNeedsReload];
//    }
//}

- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model
{
//    self.selectedCellViewModel.item = model;
//    ANDispatchBlockToMainQueue(^{
//        [self.storage reloadItem:self.selectedCellViewModel];
//    });
//    
//    self.selectedCellViewModel = nil;
    [self reloadStorage];
}

- (void)updateStorageWithModel:(ZZGridDomainModel*)model
{
//    NSArray *allItems = [self.storage itemsInSection:0];
//
//    [allItems enumerateObjectsUsingBlock:^(ZZGridCellViewModel *viewModel, NSUInteger idx, BOOL *stop) {
//        if (![viewModel isKindOfClass:[ZZGridCenterCellViewModel class]])
//        {
//            if (viewModel.item.index == model.index)
//            {
//                viewModel.item = model;
//                ANDispatchBlockToMainQueue(^{
//                   [self.storage reloadItem:viewModel];
//                });
//            }
//        }
//    }];
    [self reloadStorage];
}

- (void)updateModel:(ZZGridDomainModel*)model
{
//    NSArray *allItems = [self.storage itemsInSection:0];
//    
//    [allItems enumerateObjectsUsingBlock:^(ZZGridCellViewModel *viewModel, NSUInteger idx, BOOL *stop) {
//        if (![viewModel isKindOfClass:[ZZGridCenterCellViewModel class]])
//        {
//            if ([viewModel.item.relatedUser.mKey isEqualToString:model.relatedUser.mKey])
//            {
//                
//                
//                
//                viewModel.item = model;
//                
//                viewModel.hasDownloadedVideo = [model.relatedUser hasIncomingVideo];
//                viewModel.hasUploadedVideo = [model.relatedUser hasOutgoingVideo];//[gridModel.relatedUser hasIncomingVideo];
//                viewModel.isUploadedVideoViewed = (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
//                
//                
//             
//                viewModel.badgeNumber = @(model.relatedUser.unviewedCount);
//                
//                
//                ANDispatchBlockToMainQueue(^{
//                    [self.storage reloadItem:viewModel];
//                });
//            }
//        }
//    }];
    [self reloadStorage];
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


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
    [self.storage.delegate storageNeedsReload];
}

- (void)setupWithModels:(NSArray*)models
{
    
    
    ANSectionModel* sectionModel = [self.storage sectionAtIndex:0];
    NSMutableArray* updatedSection = [NSMutableArray arrayWithArray:sectionModel.objects ? : @[]];
    
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
    
    ZZGridCenterCellViewModel* center = [ZZGridCenterCellViewModel new];
    center.delegate = self;
    [updatedSection insertObject:center atIndex:kGridCenterCellIndex];
    
    ANDispatchBlockToMainQueue(^{
        
        [self.storage updateWithoutAnimations:^{
            ANSectionModel* updatedSectionModel = [self.storage sectionAtIndex:0 createIfNeeded:YES];
            [updatedSectionModel.objects removeAllObjects];
            [updatedSectionModel.objects addObjectsFromArray:updatedSection];
        }];
        [self reloadStorage];
    });

}

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedCellViewModel = [self.storage objectAtIndexPath:indexPath];
    [self.delegate itemSelectedWithModel:self.selectedCellViewModel];
}

- (void)setupCenterViewModelShouldHandleCameraRotation:(BOOL)shouldHandleRotation
{
    ANSectionModel* section = [self.storage sectionAtIndex:0];
    ZZGridCenterCellViewModel* model = [section objects][kGridCenterCellIndex]; // TODO safety
    model.isChangeButtonAvailable = shouldHandleRotation;
    
    ANDispatchBlockToMainQueue(^{
        [self.storage reloadItem:model];
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

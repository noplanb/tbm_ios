
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

@property (nonatomic, strong) NSArray* models;
@property (nonatomic, assign) BOOL wasInitialSetuped;

@end

@implementation ZZGridDataSource

- (void)reloadStorage
{
    [self.controllerDelegate reload];
}

- (void)setupWithModels:(NSArray*)models
{
    NSMutableArray* updatedSection = [NSMutableArray new];
    
    models = [[models.rac_sequence map:^id(ZZGridDomainModel* value) {
        
        ZZGridCellViewModel* viewModel = [ZZGridCellViewModel new];
        value.isDownloadAnimationViewed = !self.wasInitialSetuped;
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
    
    self.models = [updatedSection copy];
    
    [self reloadStorage];
    self.wasInitialSetuped = YES;
}

- (void)updateCellWithModel:(ZZGridDomainModel*)model
{
    NSInteger index = [self viewModelIndexWithModelIndex:model.index];
    if (index != NSNotFound)
    {
        ZZGridCellViewModel* viewModel = [self.models objectAtIndex:index];
        model.isDownloadAnimationViewed = !self.wasInitialSetuped;
        viewModel.item = model;
        viewModel.delegate = self;
        viewModel.hasDownloadedVideo = [model.relatedUser hasIncomingVideo];
        viewModel.hasUploadedVideo = [model.relatedUser hasOutgoingVideo];//[value.relatedUser hasIncomingVideo];
        viewModel.isUploadedVideoViewed = (model.relatedUser.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED);
        
        if (model.relatedUser.unviewedCount > 0)
        {
            viewModel.prevBadgeNumber = @(model.relatedUser.unviewedCount);
            viewModel.badgeNumber = @(model.relatedUser.unviewedCount);
        }
        
        [self _reloadModelAtIndex:index];
    }
}

- (void)updateValueOnCenterCellWithHandleCameraRotation:(BOOL)shouldHandleRotation
{
    ZZGridCenterCellViewModel* model = [self centerViewModel];
    model.isChangeButtonAvailable = shouldHandleRotation;
    [self.controllerDelegate reloadItem:model];
}

- (ZZGridCenterCellViewModel*)centerViewModel
{
    return [self.models objectAtIndex:kGridCenterCellIndex];
}

- (void)updateCenterCellWithModel:(ZZGridCenterCellViewModel*)model
{
    [self updateCellWithModel:(id)model];
}

- (id)viewModelAtIndex:(NSInteger)index
{
    id model = nil;
    if (self.models.count > index)
    {
        model = [self.models objectAtIndex:index];
    }
    return model;
}

- (NSInteger)indexForViewModel:(ZZGridCellViewModel*)model
{
    if ([model isKindOfClass:[ZZGridCellViewModel class]])
    {
         return [self viewModelIndexWithModelIndex:model.item.index];
    }
    else if ([model isKindOfClass:[ZZGridCenterCellViewModel class]])
    {
        return kGridCenterCellIndex;
    }
    return NSNotFound;
}

- (NSInteger)viewModelIndexWithModelIndex:(NSInteger)index
{
    __block id item = nil;
    
    [self.models enumerateObjectsUsingBlock:^(ZZGridCellViewModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ZZGridCellViewModel class]])
        {
            if (obj.item.index == index)
            {
                item = obj;
                *stop = YES;
            }
        }
    }];
    
    if (item)
    {
        return [self.models indexOfObject:item];
    }
    return NSNotFound;
}

#pragma mark - ViewModel Delegate

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(ZZBoolBlock)completionBlock
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

- (void)addUserToItem:(ZZGridCellViewModel*)model
{
    [self.delegate addUser];
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

- (BOOL)isVideoPlaying
{
    return [self.delegate isVideoPlaying];
}


#pragma mark - Private

- (NSArray*)models
{
    if (!_models)
    {
        _models = [NSArray new];
    }
    return _models;
}

- (void)_reloadModelAtIndex:(NSInteger)index
{
    [self.controllerDelegate reloadItemAtIndex:index];
}

@end

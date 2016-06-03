//
//  ZZGridDataSource.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDataSource.h"
#import "ZZFriendDataHelper.h"
#import "ZZGridDataProvider.h"
#import "ZZVideoDomainModel.h"

static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridDataSource ()
        <
        ZZGridCellViewModelDelegate,
        ZZGridCenterCellViewModelDelegate
        >

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, assign) BOOL wasInitialSetuped;

@end

@implementation ZZGridDataSource

- (void)reloadStorage
{
    [self.controllerDelegate reload];
}

- (NSInteger)friendsOnGridNumber
{
    ZZGridCenterCellViewModel *centerCell = [self centerViewModel];
    NSMutableArray *modelsCopy = [self.models mutableCopy];
    [modelsCopy removeObject:centerCell];
    NSArray *friends = [modelsCopy valueForKeyPath:@"@unionOfObjects.item.relatedUser"];

    return friends.count;
}


#pragma mark - ViewModels Setup After first launch

- (void)setupWithModels:(NSArray *)models
{
    NSMutableArray *updatedSection = [NSMutableArray new];

    models = [[models.rac_sequence map:^id(ZZGridDomainModel *value) {

        ZZGridCellViewModel *viewModel = [ZZGridCellViewModel new];
        value.isDownloadAnimationViewed = !self.wasInitialSetuped;
        [self _configureCellViewModel:viewModel withDomainModel:value];
        return viewModel;
    }] array];

    [updatedSection addObjectsFromArray:models];

    [self _updateActiveContactIconInModels:models];

    ZZGridCenterCellViewModel *center = [ZZGridCenterCellViewModel new];
    center.delegate = self;
    [updatedSection insertObject:center atIndex:kGridCenterCellIndex];

    self.models = [updatedSection copy];

    [self reloadStorage];
    self.wasInitialSetuped = YES;
}


#pragma mark - Update Current model

- (void)updateCellWithModel:(ZZGridDomainModel *)model
{
    NSInteger index = [self viewModelIndexWithModelIndex:model.index];
    
    if (index != NSNotFound)
    {
        ZZGridCellViewModel *viewModel = self.models[index];
        [self _updateActiveContactIconInModels:@[viewModel]];
        [self _configureCellViewModel:viewModel withDomainModel:model];
        [self _reloadModelAtIndex:index];
    }
}


#pragma mark - GridCell Configuration depends on Domain model

- (void)_updateActiveContactIconInModels:(NSArray *)models
{
    [models enumerateObjectsUsingBlock:^(ZZGridCellViewModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![obj isKindOfClass:[ZZGridCellViewModel class]])
        {
            return;
        }

        obj.hasActiveContactIcon = NO;
    }];

    ZZGridDomainModel *firstEmpty = [ZZGridDataProvider loadFirstEmptyGridElement];

    [models enumerateObjectsUsingBlock:^(ZZGridCellViewModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![obj isKindOfClass:[ZZGridCellViewModel class]])
        {
            return;
        }

        if (obj.item.index == firstEmpty.index)
        {
            *stop = YES;
            obj.hasActiveContactIcon = YES;
        }
    }];

}

- (void)_configureCellViewModel:(ZZGridCellViewModel *)viewModel withDomainModel:(ZZGridDomainModel *)model
{
    viewModel.item = model;
    viewModel.delegate = self;

    viewModel.hasDownloadedVideo = [model.relatedUser hasDownloadedVideo];

    viewModel.hasUploadedVideo = [model.relatedUser hasOutgoingVideo];

    viewModel.isUploadedVideoViewed =
            model.relatedUser.lastOutgoingVideoStatus == ZZVideoOutgoingStatusViewed;

    if (model.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
            model.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        viewModel.lastMessageDate = [ZZFriendDataHelper lastVideoSentTimeFromFriend:model.relatedUser];
    }
    else
    {
        viewModel.lastMessageDate = nil;
    }

    NSUInteger count = [ZZFriendDataHelper unviewedVideoCountWithFriendID:model.relatedUser.idTbm];

    if (count > 0)
    {
        viewModel.badgeNumber = count;
    }
    else
    {
        viewModel.badgeNumber = 0;
    }
}

- (void)updateValueOnCenterCellWithHandleCameraRotation:(BOOL)shouldHandleRotation
{
    ZZGridCenterCellViewModel *model = [self centerViewModel];
    model.isChangeButtonAvailable = shouldHandleRotation;
    [self.controllerDelegate reloadItem:model];
}

- (void)updateValueOnCenterCellWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
{
    [self centerViewModel].previewLayer = previewLayer;
}

- (ZZGridCenterCellViewModel *)centerViewModel
{
    return self.models[kGridCenterCellIndex];
}

- (id)viewModelAtIndex:(NSInteger)index
{
    id model = nil;
    if (self.models.count > index)
    {
        model = self.models[index];
    }
    return model;
}

- (NSInteger)indexForUpdatedDomainModel:(ZZGridDomainModel *)domainModel
{
    NSInteger index = [self viewModelIndexWithGridModel:domainModel];
    return index;
}

- (NSInteger)indexForFriendDomainModel:(ZZFriendDomainModel *)friendModel
{
    __block id item;

    [self.models enumerateObjectsUsingBlock:^(ZZGridCellViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[ZZGridCellViewModel class]])
        {
            if ([obj.item.relatedUser isEqual:friendModel])
            {
                item = obj;
            }
        }
    }];

    if (item)
    {
        return [self.models indexOfObject:item];
    }

    return NSNotFound;
}

- (NSInteger)indexForViewModel:(ZZGridCellViewModel *)model
{
    NSInteger index = NSNotFound;

    if ([model isKindOfClass:[ZZGridCellViewModel class]])
    {
        index = [self viewModelIndexWithGridModel:model.item];
    }
    else if ([model isKindOfClass:[ZZGridCenterCellViewModel class]])
    {
        index = kGridCenterCellIndex;
    }
    return index;
}

- (NSInteger)viewModelIndexWithGridModel:(ZZGridDomainModel *)model
{
    __block id item = nil;

    [self.models enumerateObjectsUsingBlock:^(ZZGridCellViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[ZZGridCellViewModel class]])
        {
            if ([obj.item.relatedUser.idTbm isEqualToString:model.relatedUser.idTbm])
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

- (NSInteger)viewModelIndexWithModelIndex:(NSInteger)index
{
    __block id item = nil;

    [self.models enumerateObjectsUsingBlock:^(ZZGridCellViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
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

- (BOOL)isGridRotate
{
    return [self.delegate isGridRotate];
}

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel *)viewModel
                 withCompletionBlock:(ZZBoolBlock)completionBlock
{
    [self.delegate recordingStateUpdatedToState:isEnabled
                                      viewModel:viewModel
                            withCompletionBlock:completionBlock];
    
    ZZFriendDomainModel *friendModel = viewModel.item.relatedUser;
    
    if (isEnabled || friendModel.hasApp || !friendModel.everSent)
    {
        return;
    }
    
    [self nudgeSelectedWithUserModel:friendModel];
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    [self.delegate nudgeSelectedWithUserModel:userModel];
}

- (void)playingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel *)viewModel
{
    [self.delegate toggleVideoWithViewModel:viewModel toState:isEnabled];
}

- (void)addUserToItem:(ZZGridCellViewModel *)model
{
    [self.delegate addUser];
}

- (BOOL)isGridCellEnablePlayingVideo:(ZZGridCellViewModel *)model
{
    return [self.delegate isVideoPlayingEnabledWithModel:model];
}

#pragma mark - Center Cell Delegate

- (void)switchCamera
{
    [self.delegate switchCamera];
}

- (void)cancelRecordingWithReason:(NSString *)reason
{
    [self.delegate cancelRecordingWithReason:reason];
}

- (void)showHint
{
    [self.delegate showHint];
}

- (BOOL)isVideoPlayingWithModel:(ZZGridCellViewModel *)model
{
    return [self.delegate isVideoPlayingWithFriendModel:model.item.relatedUser];
}

#pragma mark - Private

- (NSArray *)models
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

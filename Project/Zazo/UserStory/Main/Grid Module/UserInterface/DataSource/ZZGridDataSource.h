//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCell.h"
#import "ZZGridCell.h"

@class ANMemoryStorage;
@class ZZGridDomainModel;
@class ZZGridCellViewModel;
@class TBMFriend;

@protocol ZZGridDataSourceDelegate <NSObject>

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model;
- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (void)toggleVideoWithViewModel:(ZZGridCellViewModel*)model toState:(BOOL)state;
- (void)nudgeSelectedWithUserModel:(id)userModel;
- (void)showHint;
- (void)switchCamera;
- (BOOL)isVideoPlaying;

@end

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZGridDataSourceDelegate> delegate;

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath;

- (void)setupWithModels:(NSArray *)models completion:(ANCodeBlock)completion;
- (void)setupCenterViewModelShouldHandleCameraRotation:(BOOL)shouldHandleRotation;

- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model;
- (void)updateStorageWithModel:(ZZGridDomainModel*)model;
- (void)updateDataSourceWithGridModelFromNotification:(ZZGridDomainModel*)gridModel
                                  withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock;

- (void)updateDataSourceWithDownloadAnimationWithGridModel:(ZZGridDomainModel*)gridModel
                                       withCompletionBlock:(void(^)(BOOL isNewVideoDownloaded))completionBlock;

- (void)reloadStorage;
- (void)updateCenterCellWithModel:(ZZGridCenterCellViewModel*)model;
- (void)updateModel:(ZZGridDomainModel*)model;

- (void)reloadDebugStatuses;


- (ZZGridCenterCellViewModel*)centerViewModel;

@end

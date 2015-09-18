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
- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel;
- (void)toggleVideoWithViewModel:(ZZGridCellViewModel*)model toState:(BOOL)state;
- (void)nudgeSelectedWithUserModel:(id)userModel;

- (void)switchCamera;

@end

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZGridDataSourceDelegate> delegate;

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath;
- (void)setupWithModels:(NSArray*)models;
- (void)setupCenterViewModelShouldHandleCameraRotation:(BOOL)shouldHandleRotation;
- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model;
- (void)updateStorageWithModel:(ZZGridDomainModel*)model;
- (void)updateDataSourceWithGridModelFromNotification:(ZZGridDomainModel*)gridModel;
- (void)reloadStorage;

- (ZZGridCenterCellViewModel*)centerViewModel;

@end

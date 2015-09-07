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

@protocol ZZGridDataSourceDelegate <NSObject>

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model;
- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel;
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

- (ZZGridCenterCellViewModel*)centerViewModel;

@end

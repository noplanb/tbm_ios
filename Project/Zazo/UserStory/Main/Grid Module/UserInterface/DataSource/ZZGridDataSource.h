//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCell.h"
#import "ZZGridCell.h"
#import "ZZGridDataSourceInterface.h"

@class ANMemoryStorage;
@class ZZGridDomainModel;
@class ZZGridCellViewModel;

@interface ZZGridDataSource : NSObject

@property (nonatomic, weak) id<ZZGridDataSourceDelegate> delegate;
@property (nonatomic, weak) id<ZZGridDataSourceControllerDelegate> controllerDelegate;

- (void)setupWithModels:(NSArray*)models;
- (void)updateValueOnCenterCellWithHandleCameraRotation:(BOOL)shouldHandleRotation;
- (void)updateValueOnCenterCellWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

- (void)reloadStorage;
- (void)updateCenterCellWithModel:(ZZGridCenterCellViewModel*)model;

- (ZZGridCenterCellViewModel*)centerViewModel;

- (id)viewModelAtIndex:(NSInteger)index;
- (NSInteger)indexForViewModel:(ZZGridCellViewModel*)model;
- (NSInteger)viewModelindexWithGridModel:(ZZGridDomainModel*)model;
- (NSInteger)viewModelIndexWithModelIndex:(NSInteger)index;

- (void)updateCellWithModel:(ZZGridDomainModel*)model;

- (NSInteger)frindsOnGridNumber;
- (NSInteger)indexForUpdatedDomainModel:(ZZGridDomainModel*)domainModel;
- (NSInteger)indexForFriendDomainModel:(ZZFriendDomainModel*)friendModel;
- (void)updateGridPositions;

- (NSArray*)gridModels;

@end

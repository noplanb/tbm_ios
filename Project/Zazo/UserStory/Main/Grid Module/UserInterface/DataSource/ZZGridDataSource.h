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

@protocol ZZThumbnailProvider <NSObject>

- (UIImage *)thumbnailForFriend:(ZZFriendDomainModel *)friendModel;

@end

@interface ZZGridDataSource : NSObject

@property (nonatomic, weak) id <ZZGridModelPresenterInterface> presenter;
@property (nonatomic, weak) id <ZZGridDataSourceDelegate> delegate;
@property (nonatomic, weak) id <ZZGridDataSourceControllerDelegate> controllerDelegate;

@property (nonatomic, weak) id<ZZThumbnailProvider> thumbProvider;

- (void)setupWithModels:(NSArray *)models;

- (void)updateValueOnCenterCellWithHandleCameraRotation:(BOOL)shouldHandleRotation;

- (void)updateValueOnCenterCellWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

- (void)reloadStorage;

- (ZZGridCenterCellViewModel *)centerViewModel;

- (id)viewModelAtIndex:(NSInteger)index;

- (NSInteger)indexForViewModel:(ZZGridCellViewModel *)model;

- (NSInteger)viewModelIndexWithGridModel:(ZZGridDomainModel *)model;

- (NSInteger)viewModelIndexWithModelIndex:(NSInteger)index;

- (void)updateCellWithModel:(ZZGridDomainModel *)model;

- (NSInteger)friendsOnGridNumber;

- (NSInteger)indexForUpdatedDomainModel:(ZZGridDomainModel *)domainModel;

- (NSInteger)indexForFriendDomainModel:(ZZFriendDomainModel *)friendModel;

@end

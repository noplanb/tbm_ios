//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage;
@class ZZGridDomainModel;
@class ZZGridCellViewModel;

@protocol ZZGridDataSourceDelegate <NSObject>

- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model;
- (void)recordingStateUpdateWithView:(UIView*)view toState:(BOOL)isEnabled;
- (void)nudgeSelectedWithUserModel:(id)userModel;

@end

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZGridDataSourceDelegate> delegate;

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath;
- (void)setupWithModels:(NSArray*)models;
- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model;

@end

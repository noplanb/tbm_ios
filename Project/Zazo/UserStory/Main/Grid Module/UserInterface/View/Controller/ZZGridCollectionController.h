//
//  ZZGridCollectionController.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDataSource;
@class ZZFriendDomainModel;
@class ZZGridCell;

@protocol ZZGridCollectionControllerDelegate <NSObject>

- (NSArray*)items;

@end

@interface ZZGridCollectionController : NSObject

@property (nonatomic, weak) id<ZZGridCollectionControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray* initalFrames;

- (void)updateDataSource:(ZZGridDataSource*)dataSource;
- (NSInteger)indexOfFriendModelOnGrid:(ZZFriendDomainModel*)friendModel;
- (void)updateInitialViewFramesIfNeeded;
- (ZZGridCell*)gridCellWithFriendModel:(ZZFriendDomainModel*)friendModel;

@end

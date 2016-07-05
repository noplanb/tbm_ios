//
//  ZZGridViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridActionHandlerUserInterfaceDelegate.h"

@class ZZGridDataSource;
@class ZZFriendDomainModel;
@class ZZGridCellViewModel;
@class ZZGridDomainModel;
@class MenuItem;

@protocol ZZGridViewInterface <ZZGridActionHanlderUserInterfaceDelegate>

- (void)showOverflowMenuWithItems:(NSArray <MenuItem *> *)items
                         forModel:(ZZFriendDomainModel *)friendModel;

- (void)updateWithDataSource:(ZZGridDataSource *)dataSource;

- (void)showFriendAnimationWithFriendModel:(ZZFriendDomainModel *)friendModel;

- (void)updateRollingStateTo:(BOOL)isEnabled;

- (void)updateDownloadingProgressTo:(CGFloat)progress forModel:(ZZFriendDomainModel *)friendModel;

- (void)updateLoadingStateTo:(BOOL)isLoading;

- (void)updateRecordViewStateTo:(BOOL)isRecording;

- (void)updateRotatingEnabled:(BOOL)enabled;

- (BOOL)isGridRotating;

- (NSInteger)indexOfFriendModelOnGridView:(ZZFriendDomainModel *)friendModel;

- (NSInteger)indexOfBottomMiddleCell;

- (void)configureViewPositions;

- (void)prepareForCameraSwitchAnimation;
- (void)showCameraSwitchAnimation;

- (void)setBadgesHidden:(BOOL)flag forFriendModel:(ZZFriendDomainModel *)friendModel;

@end

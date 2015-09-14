//
//  ZZGridViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDataSource, ZZFriendDomainModel;

@protocol ZZGridViewInterface <NSObject>

- (void)updateWithDataSource:(ZZGridDataSource*)dataSource;
- (void)showFriendAnimationWithModel:(ZZFriendDomainModel*)friendModel;
- (void)updateRollingStateTo:(BOOL)isEnabled;

- (void)menuWasOpened;

- (CGRect)frameForIndexPath:(NSIndexPath*)indexPath;

//Hints
- (UIView*)viewForDialogs;
- (CGRect)gridGetFrameForIndexPath:(NSIndexPath*)path inView:(UIView*)view;
- (CGRect)gridGetCenterCellFrameInView:(UIView*)view;
- (CGRect)gridGetUnviewedBadgeFrameForIndexPath:(NSIndexPath*)path inView:(UIView*)view;
@end

//
// Created by Maksim Bazarov on 15/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridModuleInterface <NSObject>

- (UIView *)viewForDialog;


- (CGRect)gridGetFrameForFriend:(NSUInteger)friendCellIndex
                         inView:(UIView *)view;

- (CGRect)gridGetCenterCellFrameInView:(UIView *)view;

- (CGRect)gridGetFrameForUnviewedBadgeForFriend:(NSUInteger)friendCellIndex
                                         inView:(UIView *)view;

- (NSUInteger)lastAddedFriendOnGridIndex;
- (NSString *)lastAddedFriendOnGridName;

@end
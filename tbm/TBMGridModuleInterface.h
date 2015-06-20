//
// Created by Maksim Bazarov on 15/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridModuleInterface <NSObject>

- (CGRect)gridGetFrameForFriend:(NSUInteger)friendCellIndex
                         inView:(UIView *)view;

- (CGRect)gridGetFrameForUnviewedBadgeForFriend:(NSUInteger)friendCellIndex
                                         inView:(UIView *)view;

-(NSUInteger)lastAddedFriendOnGridIndex;

- (NSInteger)hasSentVideos:(NSUInteger)gridElementIndex;
@end
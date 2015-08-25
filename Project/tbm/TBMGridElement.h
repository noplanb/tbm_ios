//
//  TBMGridElement.h
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriend.h"
#import "_TBMGridElement.h"

@interface TBMGridElement : _TBMGridElement

// Create and destroy
+ (instancetype)create;
+ (void)destroyAll;

// Finders
+ (NSArray *)all;
+ (instancetype)findWithIntIndex:(NSInteger)i;
+ (instancetype)findWithFriend:(TBMFriend *)friend;
+ (BOOL)friendIsOnGrid:(TBMFriend *)friend;
+ (instancetype)firstEmptyGridElement;

// Getting and setting index with NSInteger instead of NSNumber
- (void)setIntIndex:(NSInteger)index;

+ (BOOL)hasSentVideos:(NSUInteger)index;

- (NSInteger)getIntIndex;
@end

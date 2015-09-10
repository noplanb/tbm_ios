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

// Finders
+ (TBMGridElement*)findWithIntIndex:(NSInteger)i;
+ (TBMGridElement*)findWithFriend:(TBMFriend *)item;

+ (BOOL)friendIsOnGrid:(TBMFriend *)item;
+ (BOOL)hasSentVideos:(NSUInteger)index;

@end

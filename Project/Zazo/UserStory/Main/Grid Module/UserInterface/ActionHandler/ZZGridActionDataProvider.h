//
//  ZZGridActionDataProvider.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@interface ZZGridActionDataProvider : NSObject

+ (NSInteger)numberOfUsersOnGrid;

+ (NSUInteger)friendsCount;
+ (BOOL)messageRecordedState;
+ (BOOL)hasSentVideos:(NSUInteger)gridIndex;
+ (BOOL)hintStateForHintType:(ZZHintsType)type;
+ (BOOL)hasFeaturesForUnlock;
@end

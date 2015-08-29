//
//  ZZDebugStateDataSource.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateCell.h"

@class ANMemoryStorage;

@interface ZZDebugStateDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)setupWithAllVideos:(NSArray*)allVideos incomeDandling:(NSArray*)income outcomeDandling:(NSArray*)outcome;

@end

//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>@class TBMFeatureKind;

@protocol TBMEventsFlowModuleDataSourceInterface <NSObject>

/**
 * Other data
 */
- (BOOL)messageRecordedState;

- (BOOL)messagePlayedState;

- (int)friendsCount;

- (NSUInteger)unviewedCount;

- (void)resetHintsState;

- (BOOL)hasSentVideos:(NSUInteger)gridIndex;
@end
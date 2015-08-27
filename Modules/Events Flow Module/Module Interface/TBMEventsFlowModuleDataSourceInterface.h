//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@class TBMFeatureKind;

@protocol TBMEventsFlowModuleDataSourceInterface <NSObject>

- (BOOL)messageRecordedState;
- (void)setMessageRecordedState:(BOOL)state;

- (BOOL)messagePlayedState;
- (void)setMessagePlayedState:(BOOL)state;

- (NSUInteger)friendsCount;
- (NSUInteger)unviewedCount;

- (void)resetHintsState;
- (BOOL)hasSentVideos:(NSUInteger)gridIndex;

@end
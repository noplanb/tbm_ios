@protocol TBMEventsFlowModuleEventHandlerInterface;

/**
 * Events flow data source - proxy for user defaults
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */


@interface TBMEventsFlowDataSource : NSObject

- (void)setPersistentState:(BOOL)state forHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler;
- (BOOL)persistentStateForHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler;

- (BOOL)messageRecordedState;
- (void)setMessageRecordedState:(BOOL)state;

- (BOOL)messageEverPlayedState;
- (void)setMessageEverPlayedState:(BOOL)state;

- (NSUInteger)friendsCount;
- (NSUInteger)unviewedCount;
- (NSUInteger)unviewedCountForCenterRightBox;

- (void)resetHintsState;
- (BOOL)hasSentVideos:(NSUInteger)gridIndex;

@end
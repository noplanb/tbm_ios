//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"
#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "ZZStoredSettingsManager.h"
#import "TBMInviteHintPresenter.h"

@interface TBMEventsFlowDataSource ()

@property(nonatomic, strong) NSDictionary* handlersKeys;

@end

@implementation TBMEventsFlowDataSource

- (BOOL)messageRecordedState
{
    return [[ZZStoredSettingsManager shared] messageEverRecorded];
}

- (void)setMessageRecordedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverRecorded:state];
}

- (BOOL)messageEverPlayedState
{
    return [[ZZStoredSettingsManager shared] messageEverPlayed];
}

- (void)setMessageEverPlayedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverPlayed:state];
}


//Other useful data
- (NSUInteger)friendsCount
{
    return [TBMFriend count];
}

- (NSUInteger)unviewedCount
{
    return [TBMFriend allUnviewedCount];
}

- (NSUInteger)unviewedCountForCenterRightBox
{
    return [TBMFriend unviewedCountForGridCellAtIndex:0];
}

- (void)resetHintsState
{
    [self setMessageEverPlayedState:NO];
    [self setMessageRecordedState:NO];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex
{
    return [TBMGridElement hasSentVideos:gridIndex];
}

// Event handler Data Source 
- (void)setPersistentState:(BOOL)state forHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler
{
    NSString* handlerClassName = NSStringFromClass([eventHandler class]);
    id key = self.handlersKeys[handlerClassName];
    if ([key isKindOfClass:[NSString class]])
    {
        [self setPersistentState:state forKey:(NSString*) key];
    };
}

- (void)setPersistentState:(BOOL)state forKey:(NSString*)key
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];

    if ([key isEqualToString:NSStringFromClass([TBMInviteHintPresenter class])])
    {
        [manager setInviteHintDidShow:state];
    }
}

- (BOOL)persistentStateForHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler
{
    return NO;
}


#pragma mark - Private

- (NSDictionary*)handlersKeys
{
    if (!_handlersKeys)
    {
        _handlersKeys = @{@"" : @""};
    }
    return _handlersKeys;
}

@end
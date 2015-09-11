//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"
#import "NSNumber+TBMUserDefaults.h"
#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "POPAnimatableProperty.h"
#import "ZZStoredSettingsManager.h"


NSString
// Events state
        *const kMessagePlayedNSUDkey = @"kMessagePlayedNSUDkey",
        *const kMessageRecordedNSUDkey = @"kMessageRecordedNSUDkey";


@interface TBMEventsFlowDataSource ()
@property(nonatomic, strong) NSDictionary *handlersKeys;
@end

@implementation TBMEventsFlowDataSource

// Viewed at least one mesaage
- (BOOL)messageEverPlayedState
{
    return [[NSNumber loadUserDefaultsObjectForKey:kMessagePlayedNSUDkey] boolValue];
}

- (void)setMessageEverPlayedState:(BOOL)state
{
    [@(state) saveUserDefaultsObjectForKey:kMessagePlayedNSUDkey];
}

// Recorded at least one mesaage
- (BOOL)messageRecordedState
{
    return [[NSNumber loadUserDefaultsObjectForKey:kMessageRecordedNSUDkey] boolValue];
}

- (void)setMessageRecordedState:(BOOL)state
{
    [@(state) saveUserDefaultsObjectForKey:kMessageRecordedNSUDkey];
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
    NSString *handlerClassName = [[eventHandler class] name];
    id key = self.handlersKeys[handlerClassName];
    if ([key isKindOfClass:[NSString class]])
    {
        [self setPersistentState:state forKey:(NSString *) key];
    };
}

- (void)setPersistentState:(BOOL)state forKey:(NSString *)key
{
    ZZStoredSettingsManager *manager = [ZZStoredSettingsManager shared];

    if ([key isEqualToString:@"TBMInviteHintPresenter"]) {
        [manager setInviteHintDidShow:state];
    }
}

- (BOOL)persistentStateForHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler
{
    return NO;
}

- (NSDictionary *)handlersKeys
{
    if (!_handlersKeys)
    {
        _handlersKeys = @{
                @"" : @"",
        };
    }
    return _handlersKeys;
}


@end
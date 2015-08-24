//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"
#import "NSNumber+TBMUserDefaults.h"


NSString
// Events state
        *const kMessagePlayedNSUDkey = @"kMessagePlayedNSUDkey",
        *const kMessageRecordedNSUDkey = @"kMessageRecordedNSUDkey";


@implementation TBMEventsFlowDataSource

// Viewed at least one mesaage
- (BOOL)messagePlayedState
{
    return [[NSNumber loadUserDefaultsObjectForKey:kMessagePlayedNSUDkey] boolValue];
}

- (void)setMessagePlayedState:(BOOL)state
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

// Other useful data
- (NSUInteger)friendsCount
{
    return [TBMFriend count];
}

- (NSUInteger)unviewedCount
{
    return [TBMFriend allUnviewedCount];
}

- (void)resetHintsState
{
    [self setMessagePlayedState:NO];
    [self setMessageRecordedState:NO];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex
{
    return [TBMGridElement hasSentVideos:gridIndex];
}

@end
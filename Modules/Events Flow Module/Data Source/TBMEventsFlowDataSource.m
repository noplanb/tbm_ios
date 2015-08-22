//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"

#define NSUD [NSUserDefaults standardUserDefaults]

NSString
// Events state
        *const kMesagePlayedNSUDkey = @"kMesagePlayedNSUDkey",
        *const kMesageRecordedNSUDkey = @"kMesageRecordedNSUDkey";


@implementation TBMEventsFlowDataSource {

}

void saveNSUDState(BOOL state, NSString *const key) {
    [NSUD setBool:state forKey:key];
    [NSUD synchronize];
}

// Viewed at least one mesaage
- (BOOL)messagePlayedState {
    return [NSUD boolForKey:kMesagePlayedNSUDkey];
}

- (void)setMessagePlayedState:(BOOL)state {
    saveNSUDState(state, kMesagePlayedNSUDkey);
}


// Recorded at least one mesaage
- (BOOL)messageRecordedState {
    return [NSUD boolForKey:kMesageRecordedNSUDkey];
}

- (void)setMessageRecordedState:(BOOL)state {
    saveNSUDState(state, kMesageRecordedNSUDkey);
}

- (NSUInteger)friendsCount {
    return [TBMFriend count];
}

- (NSUInteger)unviewedCount {
    return [TBMFriend allUnviewedCount];
}

- (void)resetHintsState {
    [self setMessagePlayedState:NO];
    [self setMessageRecordedState:NO];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex {
    return [TBMGridElement hasSentVideos:gridIndex];
}

@end
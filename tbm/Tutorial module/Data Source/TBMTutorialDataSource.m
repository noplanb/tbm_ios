//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMTutorialDataSource.h"

#define NSUD [NSUserDefaults standardUserDefaults]

NSString
        *const kInviteHint1NSUDkey = @"kInviteHint1NSUDkey",
        *const kInviteHint2NSUDkey = @"kInviteHint2NSUDkey",
        *const kPlayHintNSUDkey = @"kPlayHintNSUDkey",
        *const kRecordHintNSUDkey = @"kRecordHintNSUDkey",
        *const kSentHintNSUDkey = @"kSentHintNSUDkey",
        *const kViewedHintNSUDkey = @"kViewedHintNSUDkey";


@implementation TBMTutorialDataSource {
}

void saveNSUDState(BOOL state, const NSString *key) {
    [NSUD setBool:state forKey:key];
    [NSUD synchronize];
}

// Invite Hint 1 | every time
+ (BOOL)inviteHint1State {
    return [NSUD boolForKey:kInviteHint1NSUDkey];
}

+ (void)setInviteHint1State:(BOOL)state {
    saveNSUDState(state, kInviteHint1NSUDkey);
}

// Invite Hint 2
+ (BOOL)inviteHint2State {
    return [NSUD boolForKey:kInviteHint2NSUDkey];
}

+ (void)setInviteHint2State:(BOOL)state {
    saveNSUDState(state, kInviteHint2NSUDkey);
}

// PlayHint
+ (BOOL)playHintState {
    return [NSUD boolForKey:kPlayHintNSUDkey];
}

+ (void)setPlayHintState:(BOOL)state {
    saveNSUDState(state, kPlayHintNSUDkey);
}

// RecordHint
+ (BOOL)recordHintState {
    return [NSUD boolForKey:kRecordHintNSUDkey];
}

+ (void)setRecordHintState:(BOOL)state {
    saveNSUDState(state, kRecordHintNSUDkey);
}

// SentHint
+ (BOOL)sentHintState {
    return [NSUD boolForKey:kSentHintNSUDkey];
}

+ (void)setSentHintState:(BOOL)state {
    saveNSUDState(state, kSentHintNSUDkey);
}

// ViewedHint
+ (BOOL)viewedHintState {
    return [NSUD boolForKey:kViewedHintNSUDkey];
}

+ (void)setViewedHintState:(BOOL)state {
    saveNSUDState(state, kViewedHintNSUDkey);
}

// Viewed at least one mesaage
+ (BOOL)messagePlayedState {
    return [NSUD boolForKey:kMesagePlayedNSUDkey];
}

+ (void)setMessagePlayedState:(BOOL)state {
    saveNSUDState(state, kMesagePlayedNSUDkey);
}
// Recorded at least one mesaage
+ (BOOL)messageRecordedState {
    return [NSUD boolForKey:kMesageRecordedNSUDkey];
}

+ (void)setMessageRecordedState:(BOOL)state {
    saveNSUDState(state, kMesageRecordedNSUDkey);
}

@end
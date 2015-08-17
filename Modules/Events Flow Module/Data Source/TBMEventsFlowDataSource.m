//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"

#define NSUD [NSUserDefaults standardUserDefaults]

NSString
        *const kInviteHintNSUDkey = @"kInviteHintNSUDkey",
        *const kInviteSomeoneElseNSUDkey = @"kInviteSomeoneElseNSUDkey",
        *const kPlayHintNSUDkey = @"kPlayHintNSUDkey",
        *const kRecordHintNSUDkey = @"kRecordHintNSUDkey",
        *const kSentHintNSUDkey = @"kSentHintNSUDkey",
        *const kViewedHintNSUDkey = @"kViewedHintNSUDkey",
        *const kMessageWelcomeHintNSUDkey = @"*const kMessageWelcomeHintNSUDkey",
// Events state
        *const kMesagePlayedNSUDkey = @"kMesagePlayedNSUDkey",
        *const kMesageRecordedNSUDkey = @"kMesageRecordedNSUDkey";


@implementation TBMEventsFlowDataSource {
    BOOL _inviteHintSessionState;
    BOOL _inviteSomeoneElseHintSessionState;
    BOOL _playHintSessionState;
    BOOL _recordHintSessionState;
    BOOL _sentHintSessionState;
    BOOL _viewedHintSessionState;
    BOOL _welcomeHintSessionState;
}

void saveNSUDState(BOOL state, NSString *const key) {
    [NSUD setBool:state forKey:key];
    [NSUD synchronize];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self startSession];
    }
    return self;
}

// Invite Hint

- (BOOL)inviteHintState {
    return [NSUD boolForKey:kInviteHintNSUDkey];
}

- (void)setInviteHintState:(BOOL)state {
    saveNSUDState(state, kInviteHintNSUDkey);
}

// Invite someone else Hint
- (BOOL)inviteSomeoneElseHintState {
    return [NSUD boolForKey:kInviteSomeoneElseNSUDkey];
}

- (void)setInviteSomeoneElseHintState:(BOOL)state {
    saveNSUDState(state, kInviteSomeoneElseNSUDkey);
}

// PlayHint
- (BOOL)playHintState {
    return [NSUD boolForKey:kPlayHintNSUDkey];
}

- (void)setPlayHintState:(BOOL)state {
    saveNSUDState(state, kPlayHintNSUDkey);
}

// RecordHint
- (BOOL)recordHintState {
    return [NSUD boolForKey:kRecordHintNSUDkey];
}

- (void)setRecordHintState:(BOOL)state {
    saveNSUDState(state, kRecordHintNSUDkey);
}

// SentHint
- (BOOL)sentHintState {
    return [NSUD boolForKey:kSentHintNSUDkey];
}

- (void)setSentHintState:(BOOL)state {
    saveNSUDState(state, kSentHintNSUDkey);
}

// ViewedHint
- (BOOL)viewedHintState {
    return [NSUD boolForKey:kViewedHintNSUDkey];
}

- (void)setViewedHintState:(BOOL)state {
    saveNSUDState(state, kViewedHintNSUDkey);
}

// Viewed at least one mesaage
- (BOOL)messagePlayedState {
    return [NSUD boolForKey:kMesagePlayedNSUDkey];
}

- (void)setMessagePlayedState:(BOOL)state {
    saveNSUDState(state, kMesagePlayedNSUDkey);
}

// Welcome
- (BOOL)welcomeHintState {
    return [NSUD boolForKey:kMessageWelcomeHintNSUDkey];;
}

- (void)setWelcomeHintState:(BOOL)state {
    [NSUD boolForKey:kMessageWelcomeHintNSUDkey];
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

- (void)startSession {
    _inviteHintSessionState = NO;
    _inviteSomeoneElseHintSessionState = NO;
    _playHintSessionState = NO;
    _recordHintSessionState = NO;
    _sentHintSessionState = NO;
    _viewedHintSessionState = NO;
    _welcomeHintSessionState = NO;
}

- (void)resetHintsState {
    [self setInviteHintState:NO];
    [self setInviteSomeoneElseHintState:NO];
    [self setPlayHintState:NO];
    [self setRecordHintState:NO];
    [self setSentHintState:NO];
    [self setViewedHintState:NO];
    [self setMessagePlayedState:NO];
    [self setWelcomeHintState:NO];
    [self setMessageRecordedState:NO];
    [self startSession];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex {
    return [TBMGridElement hasSentVideos:gridIndex];
}

#pragma mark Session states

- (BOOL)inviteHintSessionState {
    return _inviteHintSessionState;
}

- (void)setInviteHintSessionState:(BOOL)state {
    _inviteHintSessionState = state;
}

- (BOOL)inviteSomeoneElseHintSessionState {
    return _inviteSomeoneElseHintSessionState;
}

- (void)setInviteSomeoneElseHintSessionState:(BOOL)state {
    _inviteSomeoneElseHintSessionState = state;
}

- (BOOL)playHintSessionState {
    return _playHintSessionState;
}

- (void)setPlayHintSessionState:(BOOL)state {
    _playHintSessionState = state;
}

- (BOOL)recordHintSessionState {
    return _recordHintSessionState;
}

- (void)setRecordHintSessionState:(BOOL)state {
    _recordHintSessionState = state;
}

- (BOOL)sentHintSessionState {
    return _sentHintSessionState;
}

- (void)setSentHintSessionState:(BOOL)state {
    _sentHintSessionState = state;
}

- (BOOL)viewedHintSessionState {
    return _viewedHintSessionState;
}

- (void)setViewedHintSessionState:(BOOL)state {
    _viewedHintSessionState = state;
}

- (BOOL)welcomeHintSessionState {
    return _welcomeHintSessionState;
}

- (void)setWelcomeHintSessionState:(BOOL)state {
    _welcomeHintSessionState = state;
}


@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>@class TBMFeatureKind;

@protocol TBMEventsFlowModuleDataSource <NSObject>

/**
 * Session states
 */
- (BOOL)inviteHintSessionState;

- (void)setInviteHintSessionState:(BOOL)state;

- (BOOL)inviteSomeoneElseHintSessionState;

- (void)setInviteSomeoneElseHintSessionState:(BOOL)state;

- (BOOL)playHintSessionState;

- (void)setPlayHintSessionState:(BOOL)state;

- (BOOL)recordHintSessionState;

- (void)setRecordHintSessionState:(BOOL)state;

- (BOOL)sentHintSessionState;

- (void)setSentHintSessionState:(BOOL)state;

- (BOOL)viewedHintSessionState;

- (void)setViewedHintSessionState:(BOOL)state;

- (BOOL)welcomeHintSessionState;

- (void)setWelcomeHintSessionState:(BOOL)state;

/**
 * Persistent states
 */

- (BOOL)inviteHintState;

- (void)setInviteHintState:(BOOL)state;

- (BOOL)inviteSomeoneElseHintState;

- (void)setInviteSomeoneElseHintState:(BOOL)state;

- (BOOL)playHintState;

- (void)setPlayHintState:(BOOL)state;

- (BOOL)recordHintState;

- (void)setRecordHintState:(BOOL)state;

- (BOOL)sentHintState;

- (void)setSentHintState:(BOOL)state;

- (BOOL)viewedHintState;

- (void)setViewedHintState:(BOOL)state;

- (BOOL)welcomeHintState;

- (void)setWelcomeHintState:(BOOL)state;

/**
 * Features state
 */

//-(BOOL)isFeatureUnlock:(TBMFeatureKind)feature;

/**
 * Other data
 */
- (BOOL)messageRecordedState;

- (BOOL)messagePlayedState;

- (int)friendsCount;

- (NSUInteger)unviewedCount;

- (void)startSession;

- (void)resetHintsState;

- (BOOL)hasSentVideos:(NSUInteger)gridIndex;
@end
/**
 * Tutorial data source - proxy for user defaults
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import <Foundation/Foundation.h>

NSString
        *const kInviteHint1NSUDkey,
        *const kInviteHint2NSUDkey,
        *const kPlayHintNSUDkey,
        *const kRecordHintNSUDkey,
        *const kSentHintNSUDkey,
        *const kViewedHintNSUDkey,
        *const kMesageWelcomeHintNSUDkey,
// Events state
        *const kMesagePlayedNSUDkey,
        *const kMesageRecordedNSUDkey;

@interface TBMTutorialDataSource : NSObject

+ (BOOL)inviteHint1State;

+ (void)setInviteHint1State:(BOOL)state;

+ (BOOL)inviteHint2State;

+ (void)setInviteHint2State:(BOOL)state;

+ (BOOL)playHintState;

+ (void)setPlayHintState:(BOOL)state;

+ (BOOL)recordHintState;

+ (void)setRecordHintState:(BOOL)state;

+ (BOOL)sentHintState;

+ (void)setSentHintState:(BOOL)state;

+ (BOOL)viewedHintState;

+ (void)setViewedHintState:(BOOL)state;

+ (BOOL)messagePlayedState;

+ (void)setMessagePlayedState:(BOOL)state;

+ (BOOL)welcomeHintState;

+ (void)setWelcomeHintState:(BOOL)state;

+ (BOOL)messageRecordedState;

+ (void)setMessageRecordedState:(BOOL)state;

+ (int)friendsCount;

+ (BOOL)unviewedCount;

@end
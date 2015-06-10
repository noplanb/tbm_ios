//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBMTutorialKind) {
    TBMTutorialKindDefault = 0,     // No hint
    TBMTutorialKindInviteHint1 = 1, // Invite Hint 1 | every time
    TBMTutorialKindInviteHint2 = 2, // Invite Hint 2
    TBMTutorialKindPlayHint = 3,    // PlayHint
    TBMTutorialKindRecordHint = 4,  // RecordHint
    TBMTutorialKindSentHint = 5,    // SentHint
    TBMTutorialKindViewedHint = 6,  // ViewedHint
};

@interface TBMTutorialPresenter : NSObject

@property(nonatomic, strong) UIView *superView;

@property(nonatomic) CGRect highlightFrame;

@property(nonatomic) CGRect highlightBadge;

@property(nonatomic) BOOL hasViewedMessages;

/**
 * Initialize tutorial module, not present it
 */
- (instancetype)initWithSuperview:(UIView *)superview
                   highlightFrame:(CGRect)highlightFrame
                   highlightBadge:(CGRect)highlightBadge
                hasViewedMessages:(BOOL)hasViewedMessages;
/**
 * Events
 *
 * Parent need to call this events when it happened
 */

/**
 *  App launched with state
 */
- (void)onAppLaunchedWithNumberofFriends:(NSUInteger)friendsCount
                           unviewedCount:(NSUInteger)unviewedCount;

/**
 * Message did play
 */
- (void)onMesageDidPlay;

/**
 *
 */
- (void)onFriendDidAdd;

/**
 *
 */
- (void)onMessageSentWithFriendsCount:(NSUInteger)friendsCount
                        unviewedCount:(NSUInteger)unviewedCount;

/**
 *
 */
- (void)onMessageViewedWithFriendsCount:(NSUInteger)friendsCount;


@end
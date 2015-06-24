//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMTutorialPresenter.h"
#import "TBMHint.h"
#import "TBMInvite1Hint.h"
#import "TBMPlayHint.h"
#import "TBMRecordHint.h"
#import "TBMSentHint.h"
#import "TBMInviteSomeoneElseHint.h"
#import "TBMViewedHint.h"
#import "TBMWelcomeHint.h"
#import "OBLoggerCore.h"

@interface TBMTutorialPresenter ()
@property(nonatomic, strong) TBMHint *hint;
@property(nonatomic, strong) TBMTutorialDataSource *dataSource;
@property(nonatomic) BOOL isRecording;
@end

@implementation TBMTutorialPresenter {

}
#pragma mark - Initialization

- (instancetype)initWithSuperview:(UIView *)parentView {
    self = [super init];
    if (self) {
        self.parentView = parentView;
    }
    return self;
}

- (void)resetSession {
    [self.dataSource startSession];
}

#pragma mark - Event handlers

- (void)applicationDidLaunch {
    OB_INFO(@"[!! TUTORIAL !!] applicationDidLaunch");
    if ([self checkRecordHintWithEvent:@selector(applicationDidLaunch)]) {
        return;
    }

    if ([self checkInvite1HintWithEvent:@selector(applicationDidLaunch)]) {
        return;
    }

    if ([self checkPlayHintWithEvent:nil]) {
        return;
    }

}

- (void)friendDidAdd {
    OB_INFO(@"[!! TUTORIAL !!] friendDidAdd");
    if ([self checkRecordHintWithEvent:@selector(friendDidAdd)]) {
        return;
    }

    if ([self checkSendWelcomeHintWithEvent:nil]) {
        return;
    }
}

- (void)messageDidReceive {
    OB_INFO(@"[!! TUTORIAL !!] messageDidReceive");
    if ([self checkPlayHintWithEvent:@selector(messageDidReceive)]) {
        return;
    }

    if ([self checkRecordHintWithEvent:nil]) {
        return;
    }
}

- (void)messageDidSend {
    OB_INFO(@"[!! TUTORIAL !!] messageDidSend");
    if ([self checkSentHintWithEvent:@selector(messageDidSend)]) {
        return;
    }

    if ([self checkInviteSomeoneElseHintWithEvent:@selector(messageDidSend)]) {
        return;
    }

}

- (void)messageDidPlay {
    OB_INFO(@"[!! TUTORIAL !!] messageDidPlay");
    [self.dataSource setMessagePlayedState:YES];

    if ([self checkRecordHintWithEvent:@selector(messageDidPlay)]) {
        return;
    }
}

- (void)messageDidStartRecording {
    self.isRecording = YES;
}

- (void)messageDidRecorded {
    OB_INFO(@"[!! TUTORIAL !!] messageDidRecorded");
    [self.dataSource setMessageRecordedState:YES];
    if (self.isRecording) {
        self.isRecording = NO;
        [self checkPlayHintWithEvent:nil];
    }
}


- (void)messageDidViewed {
    OB_INFO(@"[!! TUTORIAL !!] messageDidViewed");
    if ([self checkViewedHintWithEvent:nil]) {
        return;
    }
}

- (void)sentHintDidDismissed {
    if ([self checkInviteSomeoneElseHintWithEvent:nil]) {
        return;
    }
}

#pragma mark - Business logic

/**
 * Check hint conditions and throw even again after the hint show
 */
- (BOOL)checkInvite1HintWithEvent:(SEL)event {
    if (!self.dataSource.invite1HintShowedThisSession && [self.dataSource friendsCount] == 0) {

        [self.dataSource setInviteHint1State:YES];
        self.dataSource.invite1HintShowedThisSession = YES;
        self.hint = [TBMInvite1Hint new];
        [self showHintForEvent:event];
        return YES;
    }

    return NO;
}

- (BOOL)checkInviteSomeoneElseHintWithEvent:(SEL)event {

    if ([self.dataSource inviteSomeoneElseHintState]) {
        return NO;
    }

    if ([self.dataSource friendsCount] != 1) {
        return NO;
    }

    if (![self.dataSource messagePlayedState]) {
        return NO;
    }

    if (![self.dataSource messageRecordedState]) {
        return NO;
    }

    if (!([self.dataSource viewedHintState])) {
        return NO;
    }
    [self.dataSource setInviteSomeoneElseHintState:YES];
    self.dataSource.inviteSomeoneElseHintShowedThisSession = YES;
    self.hint = [TBMInviteSomeoneElseHint new];
    [self showHintForEvent:event];
    return YES;
}

- (BOOL)checkRecordHintWithEvent:(SEL)event {
    if ([self.hint isKindOfClass:[TBMRecordHint class]]) {
        return NO;
    }

    if (self.dataSource.recordHintShowedThisSession) {
        return NO;
    }

    if ([self.dataSource messageRecordedState]) {
        return NO;
    }

    if ([self.dataSource friendsCount] != 1) {
        return NO;
    }

    [self.dataSource setRecordHintState:YES];
    self.dataSource.recordHintShowedThisSession = YES;

    if ([self.hint isKindOfClass:[TBMPlayHint class]]) {
        [(TBMPlayHint *) self.hint addRecordTip];
    } else {
        self.hint = [TBMRecordHint new];
        [self showHintForEvent:event];
    }
    return YES;

}

- (BOOL)checkPlayHintWithEvent:(SEL)event {

    if ([self.hint isKindOfClass:[TBMPlayHint class]]) {
        return NO;
    }

    if (self.isRecording) {
        return NO;
    }

    if (self.dataSource.playHintShowedThisSession) {
        return NO;
    }

    if ([self.dataSource unviewedCount] <= 0) {
        return NO;
    }

    if ([self.dataSource messagePlayedState]) {
        return NO;
    }

    if ([self.dataSource friendsCount] != 1) {
        return NO;
    }

    if ([self.hint isKindOfClass:[TBMRecordHint class]] && ![self.dataSource messageRecordedState] && !self.dataSource.recordHintShowedThisSession) {
        [(TBMRecordHint *) self.hint addPlayTip];
    } else {
        self.hint = [TBMPlayHint new];
        [self showHintForEvent:event];
    }
    self.dataSource.playHintShowedThisSession = YES;
    [self.dataSource setPlayHintState:YES];
    [self showHintForEvent:event];

    return YES;

}

- (BOOL)checkSentHintWithEvent:(SEL)event {

    if (self.hint) {
        return NO;
    }

    if ([self.dataSource sentHintState]) {
        return NO;
    }

    if ([self.dataSource friendsCount] > 1) {
        return NO;
    }

    [self.dataSource setSentHintState:YES];
    self.dataSource.sentHintShowedThisSession = YES;
    self.hint = [TBMSentHint new];
    [self showHintForEvent:event];
    return YES;

}

- (BOOL)checkViewedHintWithEvent:(SEL)event {
    if ([self.hint isKindOfClass:[TBMViewedHint class]]) {
        return NO;
    }

    if ([self.dataSource viewedHintState] || [self.dataSource friendsCount] > 1) {
        return NO;
    }

    [self.dataSource setViewedHintState:YES];
    self.hint = [TBMViewedHint new];
    [self showHintForEvent:event];

    return YES;
}

- (BOOL)checkSendWelcomeHintWithEvent:(SEL)event {
    if ([self.dataSource friendsCount] <= 1) {
        return NO;
    }

    if ([self.dataSource hasSentVideos:[self.gridModule lastAddedFriendOnGridIndex]]) {
        return NO;
    }

    self.dataSource.welcomeHintShowedThisSession = YES;
    [self.dataSource setWelcomeHintState:YES];
    self.hint = [TBMWelcomeHint new];
    [self showHintForEvent:event];
    return YES;
}

- (void)showHintForEvent:(SEL)event {
    CGRect frame = self.parentView.bounds;
    self.hint.gridModule = self.gridModule;
    [self.hint showHintInView:self.parentView frame:frame delegate:self event:event];
}

#pragma mark - TBMHintDelegate

- (void)hintDidDismiss:(TBMHint *)hint {
    if ([self.hint isKindOfClass:[TBMSentHint class]]) {
        [self sentHintDidDismissed];
    }

    if ([self.hint isEqual:hint]) {
        self.hint = nil;
    }
}

#pragma mark - Lazy initialization

- (TBMTutorialDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[TBMTutorialDataSource alloc] init];
        [_dataSource startSession];
    }
    return _dataSource;
}


@end
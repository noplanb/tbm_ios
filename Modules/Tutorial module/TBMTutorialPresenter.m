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

- (void)applicationDidEnterBackground {
    [self.hint dismiss];
}

- (void)friendDidAdd {
    if ([self checkRecordHintWithEvent:@selector(friendDidAdd)]) {
        return;
    }

    if ([self checkSendWelcomeHintWithEvent:nil]) {
        return;
    }
}

- (void)messageDidReceive {

    if ([self checkPlayHintWithEvent:@selector(messageDidReceive)]) {
        return;
    }

    if ([self checkRecordHintWithEvent:nil]) {
        return;
    }

    if ([self.hint isKindOfClass:[TBMViewedHint class]]) {
        [self.hint dismiss];
    }
}

- (void)messageDidSend {
    if ([self checkSentHintWithEvent:@selector(messageDidSend)]) {
        return;
    }

    if ([self checkInviteSomeoneElseHintWithEvent:nil]) {
        return;
    }

}

- (void)messageDidStartPlaying {
    [self.dataSource setMessagePlayedState:YES];
}


- (void)messageDidStopPlaying {
    [self.dataSource setMessagePlayedState:YES];

    if (![self.dataSource messageRecordedState]) {
        self.dataSource.recordHintShowedThisSession = NO;
    }

    if ([self checkRecordHintWithEvent:nil]) {
        return;
    }
}


- (void)messageDidStartRecording {
    self.isRecording = YES;
}

- (void)messageDidRecorded {
    [self.dataSource setMessageRecordedState:YES];
    if (self.isRecording) {
        self.isRecording = NO;
        [self checkPlayHintWithEvent:nil];
    }
}

- (void)messageDidViewed:(NSUInteger)gridIndex {
    if ([self checkViewedHintWithEvent:nil index:gridIndex]) {
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

    if (self.hint) {
        return NO;
    }
    if ([self.dataSource inviteSomeoneElseHintShowedThisSession]) {
        return NO;
    }

    if ([self.dataSource friendsCount] != 1) {
        return NO;
    }

    if (![self.dataSource messageRecordedState]) {
        return NO;
    }

    [self.dataSource setInviteSomeoneElseHintState:YES];
    self.dataSource.inviteSomeoneElseHintShowedThisSession = YES;
    self.hint = [TBMInviteSomeoneElseHint new];
    [self showHintForEvent:event];
    return YES;
}

- (BOOL)checkRecordHintWithEvent:(SEL)event {
    if (self.hint && ![self.hint isKindOfClass:[TBMPlayHint class]]) {
        return NO;
    }

    if ([self.dataSource messageRecordedState]) {
        return NO;
    }

    if (self.dataSource.recordHintShowedThisSession) {
        return NO;
    }

    if ([self.dataSource friendsCount] != 1) {
        return NO;
    }

    if ([self.hint isKindOfClass:[TBMPlayHint class]]) {
        [(TBMPlayHint *) self.hint addRecordTip];
    } else {
        self.hint = [TBMRecordHint new];
        [self showHintForEvent:event];
    }
    [self.dataSource setRecordHintState:YES];
    self.dataSource.recordHintShowedThisSession = YES;
    return YES;

}

- (BOOL)checkPlayHintWithEvent:(SEL)event {

    if (self.hint && ![self.hint isKindOfClass:[TBMRecordHint class]]) {
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

    if ([self.hint isKindOfClass:[TBMRecordHint class]]) {
        [(TBMRecordHint *) self.hint addPlayTip];
    } else {
        self.hint = [TBMPlayHint new];
        [self showHintForEvent:event];
    }
    self.dataSource.playHintShowedThisSession = YES;
    [self.dataSource setPlayHintState:YES];
    return YES;

}

- (BOOL)checkSentHintWithEvent:(SEL)event {

    if (self.hint) {
        return NO;
    }

    if (![self.dataSource hasSentVideos:0]) {
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

- (BOOL)checkViewedHintWithEvent:(SEL)event index:(NSUInteger)index{
    if (self.hint) {
        return NO;
    }

    if (index != 0) {
        return NO;
    }

    if ([self.dataSource viewedHintState]) {
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
        self.hint = nil;
        [self sentHintDidDismissed];
    }

    if ([self.hint isEqual:hint]) {
        self.hint = nil;
    }

}

#pragma mark - TBMTutorialModuleInterface

- (void)resetHintsState {
    [self.dataSource resetHintsState];
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
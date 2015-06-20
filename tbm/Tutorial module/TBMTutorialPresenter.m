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
#import "TBMInvite2Hint.h"
#import "TBMViewedHint.h"
#import "TBMWelcomeHint.h"

@interface TBMTutorialPresenter ()
@property(nonatomic, strong) TBMHint *hint;
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

#pragma mark - Event handlers

- (void)applicationDidLaunch {
    if ([self checkRecordHintWithEvent:@selector(applicationDidLaunch)]) {
        return;
    }

    if ([self checkInvite1HintWithEvent:@selector(applicationDidLaunch)]) {
        return;
    }

    if ([self checkInvite2HintWithEvent:nil]) {
        return;
    }
}

- (void)friendDidAdd {
    if ([self checkRecordHintWithEvent:@selector(friendDidAdd)]) {
        return;
    }
}

- (void)friendDidInvite {
    if ([self checkSendWelcomeHintWithEvent:@selector(friendDidInvite)]) {
        return;
    }
}

- (void)messageDidReceive {
    if ([self checkPlayHintWithEvent:@selector(messageDidReceive)]) {
        return;
    }

    if ([self checkRecordHintWithEvent:@selector(messageDidReceive)]) {
        return;
    }

}

- (void)messageDidSend {
    if ([self checkSentHintWithEvent:@selector(messageDidSend)]) {
        return;
    }

    if ([self checkInvite2HintWithEvent:@selector(messageDidSend)]) {
        return;
    }

}

- (void)messageDidPlay {

    if ([self checkRecordHintWithEvent:@selector(messageDidPlay)]) {
        [TBMTutorialDataSource setMessagePlayedState:YES];
        return;
    }

    if ([self checkViewedHintWithEvent:nil]) {
        [TBMTutorialDataSource setMessagePlayedState:YES];
        return;
    }

}

- (void)messageDidRecorded {
    [TBMTutorialDataSource setMessageRecordedState:YES];
}

- (void)messageDidViewed {
    if ([self checkViewedHintWithEvent:nil]) {
        return;
    }
}

#pragma mark - Business logic

/**
 * Check hint conditions and throw even again after the hint show
 */
- (BOOL)checkInvite1HintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource friendsCount] == 0) {
        [TBMTutorialDataSource setInviteHint1State:YES];
        self.hint = [TBMInvite1Hint new];
        [self showHintForEvent:event];
        return YES;
    }
    return NO;
}

- (BOOL)checkInvite2HintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource friendsCount] == 1
            && [TBMTutorialDataSource playHintState]
            && [TBMTutorialDataSource recordHintState]
            && [TBMTutorialDataSource sentHintState]
            && [TBMTutorialDataSource viewedHintState]) {

        [TBMTutorialDataSource setInviteHint2State:YES];
        self.hint = [TBMInvite2Hint new];
        [self showHintForEvent:event];
        return YES;
    }
    return NO;
}

- (BOOL)checkRecordHintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource recordHintState] || [TBMTutorialDataSource messageRecordedState]) {
        return NO;
    }

    if ([TBMTutorialDataSource friendsCount] == 1) {
        [TBMTutorialDataSource setRecordHintState:YES];

        if ([self.hint isKindOfClass:[TBMPlayHint class]]) {
            [(TBMPlayHint *) self.hint addRecordTip];
        } else {
            self.hint = [TBMRecordHint new];
            [self showHintForEvent:event];
        }
        return YES;
    }
    return NO;
}

- (BOOL)checkPlayHintWithEvent:(SEL)event {
    if (![TBMTutorialDataSource playHintState] && [TBMTutorialDataSource unviewedCount] > 0
            && ![TBMTutorialDataSource messagePlayedState] && [TBMTutorialDataSource friendsCount] == 1) {


        if ([self.hint isKindOfClass:[TBMRecordHint class]]) {
            [(TBMRecordHint *) self.hint addPlayTip];
        } else {
            self.hint = [TBMPlayHint new];
            [self showHintForEvent:event];
        }
        [TBMTutorialDataSource setPlayHintState:YES];
        [self showHintForEvent:event];
    }
    return NO;

}

- (BOOL)checkSentHintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource sentHintState] || [TBMTutorialDataSource friendsCount] > 1) {
        return NO;
    }

    [TBMTutorialDataSource setSentHintState:YES];
    self.hint = [TBMSentHint new];
    [self showHintForEvent:event];
    return YES;

}

- (BOOL)checkViewedHintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource viewedHintState] || [TBMTutorialDataSource friendsCount]>1) {
        return NO;
    }

    [TBMTutorialDataSource setViewedHintState:YES];
    self.hint = [TBMViewedHint new];
    [self showHintForEvent:event];

    return YES;
}

- (BOOL)checkSendWelcomeHintWithEvent:(SEL)event {
    if ([TBMTutorialDataSource welcomeHintState] || [TBMTutorialDataSource friendsCount]>1) {
        return NO;
    }


    [TBMTutorialDataSource setWelcomeHintState:YES];
    self.hint = [TBMWelcomeHint new];
    [self showHintForEvent:event];

    return YES;
}


- (void)showHintForEvent:(SEL)event {
    CGRect frame = self.parentView.bounds;
    self.hint.gridModule = self.gridModule;
    [self.hint showHintInView:self.parentView frame:frame delegate:self event:event];
}


@end
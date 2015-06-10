//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMTutorialPresenter.h"
#import "TBMTutorialView.h"

@interface TBMTutorialPresenter ()
@property(nonatomic, strong) TBMTutorialView *tutorialView;
@end

@implementation TBMTutorialPresenter {

}
#pragma mark - Initialization

- (instancetype)initWithSuperview:(UIView *)superview highlightFrame:(CGRect)highlightFrame highlightBadge:(CGRect)highlightBadge hasViewedMessages:(BOOL)hasViewedMessages {
    self = [super init];
    if (self) {
        self.superView = superview;
        self.highlightFrame = highlightFrame;
        self.highlightBadge = highlightBadge;
        self.hasViewedMessages = hasViewedMessages;
    }
    return self;
}

#pragma mark - Event handlers

- (void)onAppLaunchedWithNumberofFriends:(NSUInteger)friendsCount unviewedCount:(NSUInteger)unviewedCount {
    [self presentTutorial:TBMTutorialKindDefault];
}

- (void)onMesageDidPlay {

}

- (void)onFriendDidAdd {

}

- (void)onMessageSentWithFriendsCount:(NSUInteger)friendsCount unviewedCount:(NSUInteger)unviewedCount {

}

- (void)onMessageViewedWithFriendsCount:(NSUInteger)friendsCount {

}

#pragma mark - Presentation

- (void)presentTutorial:(TBMTutorialKind)tutorialKind {

    if (self.superView) {
        self.tutorialView.text = @"Press and hold to record";
        self.tutorialView.arrowKind = TBMTutorialArrowPointFromTopToHorizBottom;
        self.tutorialView.hidden = NO;
    }
}

#pragma mark - Lazy initialization

- (TBMTutorialView *)tutorialView {
    if (!_tutorialView) {
        CGRect frame = self.superView.bounds;
        _tutorialView = [[TBMTutorialView alloc] initWithFrame:frame];
        _tutorialView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.86f];
        _tutorialView.framesToCutOut = @[
                //Used as main bounds and should be first in array
                [UIBezierPath bezierPathWithRect:self.highlightFrame],
                [UIBezierPath bezierPathWithOvalInRect:self.highlightBadge]
        ];

        [self.superView addSubview:_tutorialView];
        [self.superView bringSubviewToFront:_tutorialView];
        _tutorialView.backgroundColor = [UIColor clearColor];
        _tutorialView.hidden = YES;
        _tutorialView.userInteractionEnabled = YES;
    }
    return _tutorialView;
}


@end
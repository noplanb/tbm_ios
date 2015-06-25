//
// Created by Maksim Bazarov on 26.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSecretGestureRecognizer.h"

@interface TBMSecretGestureRecognizer ()

@property(nonatomic, assign) NSUInteger currentStep;
@property(nonatomic, strong) NSTimer *touchesTimer;

@end

@implementation TBMSecretGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.currentStep = 0;
    }
    return self;

}

#pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"+ touchesBegan");

    if (self.currentStep > 0) {
        self.currentStep = 0;
        [self stateCanceled];
    }

    NSSet *logoTouches = [event touchesForView:self.logoView];
    if ([logoTouches count]) {
        [self statePossible];
        self.touchesTimer = [NSTimer scheduledTimerWithTimeInterval:TBMSecretGestureLongPressTime
                                                             target:self
                                                           selector:@selector(checkLongPress)
                                                           userInfo:nil repeats:NO];
    } else {
        [self stateCanceled];
    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self viewsInstalled]) {
        return;
    }

    if (self.currentStep <= TBMSecretGestureRecognizerStepDefault) {
        return;
    }

    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    UIView *touchedView = [self.view hitTest:locationPoint withEvent:event];

    if ([touchedView isEqual:self.logoView]) {
        if (self.currentStep == TBMSecretGestureRecognizerStepPanedToMenu) {
            self.currentStep = TBMSecretGestureRecognizerStepPanedToLogo;
            [self stateChanged];
        }
    }

    if ([touchedView isEqual:self.menuView]) {
        if (self.currentStep == TBMSecretGestureRecognizerStepLogoLongpressed
                || self.currentStep == TBMSecretGestureRecognizerStepPanedToMenu) {
            self.currentStep = TBMSecretGestureRecognizerStepPanedToMenu;
            [self stateChanged];
        } else {
            [self stateCanceled];
        }
    }

    // Not in any view? then fail gesture
    if (![touchedView isEqual:self.container]
            && ![touchedView isEqual:self.menuView]
            && ![touchedView isEqual:self.logoView]) {
        [self stateCanceled];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.currentStep == TBMSecretGestureRecognizerStepPanedToLogo) {
        [self stateEnded];
    } else {
        [self stateCanceled];
    }

}

- (void)checkLongPress {
    if (self.currentStep == TBMSecretGestureRecognizerStepDefault) {
        [self stateBegan];
    }

}

#pragma mark - States

- (void)statePossible {
    self.delaysTouchesBegan = YES;
    self.currentStep = TBMSecretGestureRecognizerStepDefault;
    self.state = UIGestureRecognizerStatePossible;
}

- (void)stateBegan {
    self.currentStep = TBMSecretGestureRecognizerStepLogoLongpressed;
    self.state = UIGestureRecognizerStateBegan;
}

- (void)stateChanged {
    self.state = UIGestureRecognizerStateChanged;
}

- (void)stateCanceled {
    self.delaysTouchesEnded = YES;
    self.currentStep = 0;
    self.touchesTimer = nil;
    self.state = UIGestureRecognizerStateCancelled;
    NSLog(@"((( stateCanceled");

}

- (void)stateEnded {
    self.delaysTouchesEnded = YES;
    self.currentStep = 0;
    self.touchesTimer = nil;
    self.state = UIGestureRecognizerStateEnded;
    NSLog(@"!!! stateEnded  !!!");
}

#pragma mark - Helpers

- (BOOL)viewsInstalled {
    return (self.container && self.menuView && self.logoView);
}

@end
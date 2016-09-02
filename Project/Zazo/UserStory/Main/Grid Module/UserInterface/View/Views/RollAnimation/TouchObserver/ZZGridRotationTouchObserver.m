//
//  ZZTouchObserver.m
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridRotationTouchObserver.h"
#import "ZZRotator.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZGridHelper.h"
@import pop;

static CGFloat const kStartGridRotationOffset = 5;

@interface ZZGridRotationTouchObserver () <ZZRotatorDelegate, UIGestureRecognizerDelegate, ZZGridViewDelegate>

@property (nonatomic, assign, readwrite) BOOL isRotating;

@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, strong) ZZGridView *gridView;
@property (nonatomic, assign) CGFloat startOffset;

@property (nonatomic, strong) ZZRotator *rotator;
@property (nonatomic, strong) ZZGridHelper *gridHelper;

@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressRecognizer;


@end

@implementation ZZGridRotationTouchObserver

- (void)updatedFrame:(CGRect)frame
{
    [self.gridHelper setFrame:frame];
}

- (instancetype)initWithGridView:(ZZGridView *)gridView
{
    self = [super init];
    if (self)
    {
        _enabled = YES;

        self.gridView = gridView;
        self.gridView.delegate = self;
        self.gridHelper = [ZZGridHelper new];

        [self _makeRotationRecognizer];
        [self _makeLongPressGestureRecognizer];
        
        self.rotator = [[ZZRotator alloc] initWithAnimationCompletionBlock:^{
            self.isRotating = NO;
        }];

        self.rotator.gridView = gridView;
        self.rotator.delegate = self;
    }
    return self;
}

- (void)_makeRotationRecognizer
{
    self.rotationRecognizer = [[ZZRotationGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handleRotationGesture:)];
    self.rotationRecognizer.delegate = self;
    [self.gridView.itemsContainerView addGestureRecognizer:self.rotationRecognizer];
}

- (void)_makeLongPressGestureRecognizer
{
    //    UIWindow *stopWindow = [UIApplication sharedApplication].keyWindow;
    //    [[[stopWindow rac_signalForSelector:@selector(sendEvent:)] filter:^BOOL(RACTuple *touches) {
    //
    //        BOOL isTouchEnabled = NO;
    //        BOOL isTouchInArea = NO;
    //        for (id event in touches)
    //        {
    //            NSSet *touches = [event allTouches];
    //            UITouch *touch = [touches anyObject];
    //            isTouchEnabled = (touch.phase == UITouchPhaseBegan);
    //
    //            CGPoint location = [touch locationInView:stopWindow];
    //            CGRect containerRect = self.gridView.itemsContainerView.frame;
    //            isTouchInArea = CGRectContainsPoint(containerRect, location);
    //        };
    //
    //        BOOL isUserRotation = self.rotationRecognizer.state != UIGestureRecognizerStatePossible;
    //
    //        return self.isMoving && isTouchEnabled && isTouchInArea && !isUserRotation;
    //
    //    }] subscribeNext:^(RACTuple *touches) {
    //        [self.rotator jumpToNearest];
    //    }];
    
    self.pressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(_handlerLongPressWithRecognizer:)];
    self.pressRecognizer.delegate = self;
    [self.gridView.itemsContainerView addGestureRecognizer:self.pressRecognizer];
}

- (void)_setupStateObserver
{
    RACSignal *featureUnlocked = RACObserve([ZZGridActionStoredSettings shared], carouselFeatureEnabled);
    RACSignal *featureEnabled = RACObserve(self, enabled);
    
    [[RACSignal
      combineLatest:@[featureUnlocked, featureEnabled]
      reduce:^id(NSNumber *unlocked, NSNumber *enabled) {
        return @(unlocked.boolValue && enabled.boolValue);
      }]
      subscribeNext:^(id x) {
        self.rotationRecognizer.enabled = [x boolValue];
        self.pressRecognizer.enabled = [x boolValue];
      }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (<#condition#>) {
        <#statements#>
    }
    
    
    UIPanGestureRecognizer
    
    // Prevent scrolling from horizontal swiping:
    CGPoint velocity = [gestureRecognizer velocityInView:self.gridView];
    return fabs(velocity.y) > fabs(velocity.x);
}

- (void)handleRotationGesture:(ZZRotationGestureRecognizer *)recognizer
{
    if ([self _isEnableRotationWithRecorgnizer:recognizer])
    {
        switch (recognizer.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                self.startOffset = self.gridView.calculatedCellsOffset;
                [self.rotator stopAnimations];
            }
                break;

            case UIGestureRecognizerStateChanged:
            {
                CGPoint rotationOffset = [recognizer translationInView:self.gridView];

                if (ABS(rotationOffset.x) > kStartGridRotationOffset ||
                    ABS(rotationOffset.y) > kStartGridRotationOffset)
                {
                    self.isRotating = YES;
                    CGFloat currentAngle = [recognizer currentAngleInView:self.gridView];
                    CGFloat startAngle = [recognizer startAngleInView:self.gridView];
                    CGFloat deltaAngle = currentAngle - startAngle;

                    self.gridView.calculatedCellsOffset = self.startOffset + deltaAngle;
                }
            }
                break;

            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                if (self.isRotating)
                {
                    [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView]];
                }

            }
                break;
            default:
                break;
        }
    }
    else
    {
        if (self.isRotating)
        {
            self.isRotating = NO;
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView]];
        }
    }
}

- (void)placeCells
{
    [self.rotator rotateCells:self.gridView.items
                      onAngle:self.gridView.calculatedCellsOffset
                     withGrid:self.gridHelper];
}

- (BOOL)_isEnableRotationWithRecorgnizer:(ZZRotationGestureRecognizer *)recognizer
{
    BOOL isEnable = NO;
    CGPoint location = [recognizer locationInView:recognizer.view];
    CGFloat kAccessOffset = 50;
    CGFloat viewWidth = CGRectGetWidth(recognizer.view.frame);
    isEnable = (viewWidth - kAccessOffset) > location.x;

    return isEnable;
}

#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    [self.rotator stopDecayAnimationIfNeeded];
}

#pragma mark - Stop Rotation methods

- (void)_handlerLongPressWithRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    NSLog(@"state = %d", recognizer.state);
}

@end

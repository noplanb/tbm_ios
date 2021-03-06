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

static CGFloat const kStartGridRotationOffset = 20;

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
        
        [self _setupStateObserver];
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
    UILongPressGestureRecognizer *pressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(_handleLongPressWithRecognizer:)];
    
    pressRecognizer.delegate = self;
    pressRecognizer.minimumPressDuration = 0.01;
    pressRecognizer.cancelsTouchesInView = NO;
    pressRecognizer.delaysTouchesEnded = NO;
//    [pressRecognizer requireGestureRecognizerToFail:self.rotationRecognizer];
    [self.gridView.itemsContainerView addGestureRecognizer:pressRecognizer];
    self.pressRecognizer = pressRecognizer;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.rotationRecognizer && otherGestureRecognizer == self.pressRecognizer) {
        return YES;
    }
    
    if (gestureRecognizer == self.pressRecognizer && otherGestureRecognizer == self.rotationRecognizer)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.pressRecognizer)
    {
        return self.rotationRecognizer.state == UIGestureRecognizerStatePossible && self.isRotating;
    }
    
    if (gestureRecognizer == self.rotationRecognizer)
    {
        if (self.isRotating)
        {
            return YES;
        }
        
        UIPanGestureRecognizer *recognizer = (id)gestureRecognizer;
        
        CGPoint velocity = [recognizer velocityInView:self.gridView];
        CGPoint point = [recognizer locationInView:self.gridView];
        CGFloat width = self.gridView.bounds.size.width;
        CGFloat edgeWidth = width/6;
        
        BOOL isVertical = fabs(velocity.y) > fabs(velocity.x);
        BOOL isDirectionRight = velocity.x > 0;
        BOOL isDirectionLeft = velocity.x < 0;
        BOOL isStartedFromRightEdge = isDirectionRight && point.x < edgeWidth;
        BOOL isStartedFromLeftEdge = isDirectionLeft && width - point.x < edgeWidth;
        BOOL isStartedFromEdge = isStartedFromLeftEdge || isStartedFromRightEdge;
        
        // WHY: https://zazo.fogbugz.com/f/cases/1108/Tweaks-to-touch-control-for-open-tabs-and-spin-friends
        
        return isVertical || !isStartedFromEdge;
    }
    
    return YES;
}

- (void)handleRotationGesture:(ZZRotationGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.isRotating = NO;
            [self.rotator stopAnimations];
            self.pressRecognizer.enabled = NO;
        }
            break;

        case UIGestureRecognizerStateChanged:
        {
            [self startRotationIfNeeded:recognizer];
            
            if (self.isRotating)
            {
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
            self.pressRecognizer.enabled = YES;
            if (self.isRotating)
            {
                [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView]];
            }
            else
            {
                [self.rotator jumpToNearest];
            }

        }
            break;
        default:
            break;
    }
}

- (void)startRotationIfNeeded:(ZZRotationGestureRecognizer *)recognizer
{
    CGPoint rotationOffset = [recognizer translationInView:self.gridView];
    
    if (self.isRotating)
    {
        return;
    }
    
    if (ABS(rotationOffset.x) < kStartGridRotationOffset &&
        ABS(rotationOffset.y) < kStartGridRotationOffset)
    {
        return;
    }
    
    CGFloat currentAngle = [recognizer currentAngleInView:self.gridView];
    CGFloat startAngle = [recognizer startAngleInView:self.gridView];
    CGFloat deltaAngle = currentAngle - startAngle;

    self.startOffset = self.gridView.calculatedCellsOffset - deltaAngle;
    self.isRotating = YES;
}

- (void)finishRotation
{
    [self.rotator stopAnimations];
    self.isRotating = NO;
}

- (void)placeCells
{
    [self.rotator rotateCells:self.gridView.items
                      onAngle:self.gridView.calculatedCellsOffset
                     withGrid:self.gridHelper];
}

#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    [self.rotator stopDecayAnimationIfNeeded];
}

#pragma mark - Stop Rotation methods

- (void)_handleLongPressWithRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.rotator stopAnimations];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.rotator jumpToNearest];
            break;
        default:
            break;
    }
}

@end

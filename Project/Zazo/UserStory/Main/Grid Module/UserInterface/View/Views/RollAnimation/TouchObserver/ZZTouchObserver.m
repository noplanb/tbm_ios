//
//  ZZTouchObserver.m
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZTouchObserver.h"
#import "ZZRotator.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZGridHelper.h"

static CGFloat const kTouchOffset = 7;

@interface ZZTouchObserver () <ZZRotatorDelegate, UIGestureRecognizerDelegate, ZZGridViewDelegate>

@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, assign) CGFloat startOffset;

@property (nonatomic, strong) ZZRotator* rotator;
@property (nonatomic, strong) ZZGridHelper* gridHelper;

@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, assign) BOOL isGridMoved;

@end

@implementation ZZTouchObserver

- (void)updatedFrame:(CGRect)frame
{
    [self.gridHelper setFrame:frame];
}

- (instancetype)initWithGridView:(ZZGridView*)gridView
{
    self = [super init];
    if (self)
    {
        self.gridView = gridView;
        self.gridView.delegate = self;
        self.gridHelper = [ZZGridHelper new];
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
            for (id event in touches)
            {
                NSSet* touches = [event allTouches];
                UITouch* touch = [touches anyObject];
                [self observeTouch:touch withEvent:event];
            };
        }];
        
        self.rotationRecognizer = [[ZZRotationGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleRotationGesture:)];
        
        self.rotationRecognizer.delegate = self;
        [self.gridView addGestureRecognizer:self.rotationRecognizer];
        
        self.rotator = [[ZZRotator alloc] initWithAnimationCompletionBlock:^{
            self.isGridMoved = NO;
        }];
        self.rotator.delegate = self;
    }
    return self;
}

- (void)observeTouch:(UITouch *)touch withEvent:(id)event
{
    if (YES) //([ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        if (touch.phase == UITouchPhaseBegan)
        {
            if (self.isGridMoved)
            {
                [self.rotator stopDecayAnimationIfNeeded:self.rotator.decayAnimation onGrid:self.gridView];
                
            }
            else
            {
                self.initialLocation = [touch locationInView:self.gridView.itemsContainerView];
            }
        }
        
        if (touch.phase == UITouchPhaseMoved && self.gridView.isRotationEnabled && [self shouldMoveWithTouch:touch])
        {
            CGPoint location = [touch locationInView:self.gridView.itemsContainerView];
            [self.delegate stopPlaying];
            if (!self.isMoving)
            {
                self.isMoving = YES;
                self.initialLocation = location;
            }
        }
    }
}

- (BOOL)shouldMoveWithTouch:(UITouch*)touch
{
    BOOL shouldMove = NO;
    
    CGPoint location = [touch locationInView:self.gridView.itemsContainerView];
    CGFloat midX;
    CGFloat midY;
    if (location.x > self.initialLocation.x)
    {
        midX = location.x - self.initialLocation.x;
    }
    else
    {
        midX = self.initialLocation.x - location.x;
    }
    
    
    if (location.y > self.initialLocation.y)
    {
        midY = location.y - self.initialLocation.y;
    }
    else
    {
        midY = self.initialLocation.y - location.y;
    }
    
    if (midY > kTouchOffset || midX > kTouchOffset)
    {
        shouldMove = YES;
    }
    
    return shouldMove;
}

- (void)handleRotationGesture:(ZZRotationGestureRecognizer*)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"ZZMOVINGGRIDVIEW START TOUCH");
            self.startOffset = self.gridView.cellsOffset;
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer locationInView:self.gridView];
            
            CGFloat currentAngle = [recognizer currentAngleInView:self.gridView];
            CGFloat startAngle = [recognizer startAngleInView:self.gridView];
            CGFloat deltaAngle = (CGFloat)((CGFloat)currentAngle - (CGFloat)startAngle);
            NSUInteger indexPath = [self.gridHelper indexWithPoint:point];
            if (indexPath == 8)
            {
                return;
            }
            self.gridView.cellsOffset = self.startOffset + (CGFloat) (deltaAngle);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            self.isGridMoved = YES;
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView] onCarouselView:self.gridView];
        }
            break;
        default: break;
    }
}


- (void)placeCells
{
    [self.rotator rotateCells:self.gridView.items onAngle:self.gridView.cellsOffset withGrid:self.gridHelper];
}

- (void)bounceCells
{
    self.gridView.cellsOffset = self.gridView.cellsOffset;
    CGFloat angle = [ZZGeometryHelper nearestFixedPositionFrom:self.gridView.cellsOffset];
    [self.rotator bounceAnimationToAngle:angle onCarouselView:self.gridView];
}

#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    [self.rotator stopDecayAnimationIfNeeded:anim onGrid:self.gridView];
}

@end

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

static CGFloat const kStartGridRotationOffset = 10;

@interface ZZGridRotationTouchObserver () <ZZRotatorDelegate, UIGestureRecognizerDelegate, ZZGridViewDelegate>

@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, assign) CGFloat startOffset;

@property (nonatomic, strong) ZZRotator* rotator;
@property (nonatomic, strong) ZZGridHelper* gridHelper;

@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;

@end

@implementation ZZGridRotationTouchObserver

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
        
        self.rotationRecognizer = [[ZZRotationGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleRotationGesture:)];
        self.rotationRecognizer.delegate = self;
        [self.gridView.itemsContainerView addGestureRecognizer:self.rotationRecognizer];
        
        [RACObserve([ZZGridActionStoredSettings shared], spinHintWasShown) subscribeNext:^(id x) {
            self.rotationRecognizer.enabled = [x boolValue];
        }];
        
        self.rotator = [[ZZRotator alloc] initWithAnimationCompletionBlock:^{
            self.isMoving = NO;
//            [self _updateOriginalFramesAfterRotationStoped];
        }];
        
        self.rotator.gridView = gridView;
        [self _setupStopRotationHandler];
        
        self.rotator.delegate = self;
    }
    return self;
}

- (BOOL)isGridRotate
{
    return self.isMoving;
}

- (void)handleRotationGesture:(ZZRotationGestureRecognizer*)recognizer
{
    if ([self _isEnableRotationWithRecorgnizer:recognizer])
    {
        switch (recognizer.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                self.startOffset = self.gridView.calculatedCellsOffset;
                [self.rotator stopAnimationsOnGrid:self.gridView];
                
            } break;
                
            case UIGestureRecognizerStateChanged:
            {
                CGPoint rotationOffset = [recognizer translationInView:self.gridView];
                
                if ((rotationOffset.x > kStartGridRotationOffset || rotationOffset.x < -kStartGridRotationOffset) ||
                    (rotationOffset.y > kStartGridRotationOffset || rotationOffset.y < -kStartGridRotationOffset))
                {
                    self.isMoving = YES;
                    CGFloat currentAngle = [recognizer currentAngleInView:self.gridView];
                    CGFloat startAngle = [recognizer startAngleInView:self.gridView];
                    CGFloat deltaAngle = currentAngle - startAngle;
                    
                    self.gridView.calculatedCellsOffset = self.startOffset + deltaAngle;
                }
            } break;
                
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                if (self.isMoving)
                {
                    [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView] onCarouselView:self.gridView];
                }
          
            } break;
            default: break;
        }
    }
    else
    {
        if (self.isMoving)
        {
            self.isMoving = NO;
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView] onCarouselView:self.gridView];
        }
    }
}

- (void)placeCells
{
    [self.rotator rotateCells:self.gridView.items onAngle:self.gridView.calculatedCellsOffset withGrid:self.gridHelper];
}

- (BOOL)_isEnableRotationWithRecorgnizer:(ZZRotationGestureRecognizer*)recognizer
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
    [self.rotator stopDecayAnimationIfNeeded:anim onGrid:self.gridView];
}


#pragma mark - Update original frames

//- (void)_updateOriginalFramesAfterRotationStoped
//{
//    __block NSMutableArray* updatedFrames = [NSMutableArray array];
//    
//    [self.gridView.items enumerateObjectsUsingBlock:^(UIView*  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGPoint centerView = CGPointMake(view.centerX, view.centerY);
//        [[self.gridHelper initialFrames] enumerateObjectsUsingBlock:^(NSValue*  _Nonnull value, NSUInteger index, BOOL * _Nonnull stop) {
//            CGRect rect = [value CGRectValue];
//            if (CGRectContainsPoint(rect, centerView))
//            {
//                [updatedFrames addObject:value];
//            }
//        }];
//    }];
//    
//    [self.gridHelper updateOriginalFramesWithActualFrames:updatedFrames];
//}


#pragma mark - Stop Rotation methods

- (void)_setupStopRotationHandler
{
    UIWindow* stopWindow = [UIApplication sharedApplication].keyWindow;
    [[[stopWindow rac_signalForSelector:@selector(sendEvent:)] filter:^BOOL(RACTuple *touches) {
        
        BOOL isTouchEnabled = NO;
        BOOL isTouchInArea = NO;
        for (id event in touches)
        {
            NSSet* touches = [event allTouches];
            UITouch* touch = [touches anyObject];
            isTouchEnabled = (touch.phase == UITouchPhaseBegan);
            
            CGPoint location = [touch locationInView:stopWindow];
            CGRect containerRect = self.gridView.itemsContainerView.frame;
            isTouchInArea = CGRectContainsPoint(containerRect, location);
        };

        return (self.isMoving && isTouchEnabled && isTouchInArea);

    }] subscribeNext:^(RACTuple *touches) {
        [self.rotationRecognizer stateChanged];
    }];
}

@end

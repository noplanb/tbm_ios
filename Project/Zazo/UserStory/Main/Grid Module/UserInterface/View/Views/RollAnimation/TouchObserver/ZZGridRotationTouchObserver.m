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

@interface ZZGridRotationTouchObserver () <ZZRotatorDelegate, UIGestureRecognizerDelegate, ZZGridViewDelegate>

@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, assign) CGFloat startOffset;

@property (nonatomic, strong) ZZRotator* rotator;
@property (nonatomic, strong) ZZGridHelper* gridHelper;

@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;

@property (nonatomic, assign) ZZSpinDirection gestureDirection;

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
        [self.gridView addGestureRecognizer:self.rotationRecognizer];
        
        [RACObserve([ZZGridActionStoredSettings shared], spinHintWasShown) subscribeNext:^(id x) {
            self.rotationRecognizer.enabled = [x boolValue];
        }];
        
        self.rotator = [[ZZRotator alloc] initWithAnimationCompletionBlock:^{
            self.isMoving = NO;
        }];
        self.rotator.delegate = self;
    }
    return self;
}

- (void)handleRotationGesture:(ZZRotationGestureRecognizer*)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {//TODO: handle rotation only if it starts on friend cell
//            UIView* view = [self.gridView hitTest:[recognizer locationInView:self.gridView] withEvent:nil];
//            if (view && [self.gridView.items containsObject:view])
//            {
                self.startOffset = self.gridView.calculatedCellsOffset;
                [self.rotator stopAnimationsOnGrid:self.gridView];
//            }
        } break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat currentAngle = [recognizer currentAngleInView:self.gridView];
            CGFloat startAngle = [recognizer startAngleInView:self.gridView];
            CGFloat deltaAngle = currentAngle - startAngle;
            self.gridView.calculatedCellsOffset = self.startOffset + deltaAngle;
        } break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self.gridView] onCarouselView:self.gridView];
        } break;
        default: break;
    }
}

- (void)placeCells
{
    [self.rotator rotateCells:self.gridView.items onAngle:self.gridView.calculatedCellsOffset withGrid:self.gridHelper];
}


#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    [self.rotator stopDecayAnimationIfNeeded:anim onGrid:self.gridView];
}

@end

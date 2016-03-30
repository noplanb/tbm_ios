//
//  ZZSecretScreenController.m
//  Zazo
//
//  Created by ANODA on 10/26/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import CoreMotion;

#import "ZZSecretScreenController.h"
#import "ZZBaseTouchController.h"
#import "ZZTouchControllerWithTouchDelay.h"
#import "ZZTouchControllerWithoutDelay.h"
#import "ZZStrategyNavigationLeftRight.h"
#import "ZZEnvelopStrategy.h"

NSString * const ZZNeedsToShowSecretScreenNotificationName = @"ZZNeedsToShowSecretScreenNotificationName";

static CGFloat const kDefaultTouchDelay = 0.2;

@interface ZZSecretScreenController ()

@property (nonatomic, strong) ZZBaseTouchController* touchController;
@property (nonatomic, strong) CMMotionManager* motionManager;

@end

@implementation ZZSecretScreenController

+ (instancetype)startObserveWithType:(ZZSecretScreenObserveType)observeType
                           touchType:(ZZSecretScreenTouchType)touchType
                              window:(UIWindow*)window
                     completionBlock:(ANCodeBlock)completionBlock
{
    ZZSecretScreenController* secretController = [ZZSecretScreenController new];
    
    secretController.touchController = [secretController _touchControllerWithType:touchType
                                                                      observeType:observeType
                                                                  completionBlock:completionBlock];
    
    
#ifdef RELEASE
    
    [secretController _startObserveWithWindow:window];
    
#else
    
    [secretController _startObserveWithWindow:window];
    [secretController _setupMotionControllerWithCompletionBlock:completionBlock];

    [[NSNotificationCenter defaultCenter] addObserver:secretController
                                             selector:@selector(_needsToShowSecretScreenNotification)
                                                 name:ZZNeedsToShowSecretScreenNotificationName
                                               object:nil];
#endif
    
    return secretController;
}


#pragma mark - Private

- (void)_needsToShowSecretScreenNotification
{
    self.touchController.completionBlock();
}

- (void)_setupMotionControllerWithCompletionBlock:(ANCodeBlock)completionBlock
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = .17;
    NSOperationQueue* opQueue = [NSOperationQueue new];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:opQueue
                                            withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CGFloat accelerationValue = 2.3;
        CMAcceleration userAcceleration = motion.userAcceleration;
        if (fabs(userAcceleration.x) > accelerationValue ||
            fabs(userAcceleration.y) > accelerationValue )
        {
            ANDispatchBlockToMainQueue(^{
                if (completionBlock &&
                    [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
                {
                    completionBlock();
                }
            });
        }
    }];
}

- (ZZBaseTouchController*)_touchControllerWithType:(ZZSecretScreenTouchType)touchType
                                       observeType:(ZZSecretScreenObserveType)observeType
                                   completionBlock:(void(^)())completionBlock
{
    ZZBaseTouchController* touchController = nil;
    switch (touchType)
    {
        case ZZSecretScreenTouchTypeNone:
        {
            touchController = [[ZZTouchControllerWithoutDelay alloc] initWithStrategy:[self _strategyWithType:observeType]
                                                                  withCompletionBlock:completionBlock];
        } break;
        case ZZSecretScreenTouchTypeWithoutDelay:
        {
            touchController = [[ZZTouchControllerWithoutDelay alloc] initWithStrategy:[self _strategyWithType:observeType]
                                                                  withCompletionBlock:completionBlock];
            
        } break;
        case ZZSecretScreenTouchTypeWithDelay:
        {
            touchController = [[ZZTouchControllerWithTouchDelay alloc] initWithDelay:kDefaultTouchDelay
                                                                        withStrategy:[self _strategyWithType:observeType]
                                                                 withCompletionBlock:completionBlock];
        } break;
    }
    
    return touchController;
}

- (id<ZZSecretScreenStrategy>)_strategyWithType:(ZZSecretScreenObserveType)type
{
    id <ZZSecretScreenStrategy> strategy;
    
    switch (type)
    {
        case ZZNavigationBarLeftRightObserveType:
        {
            strategy = [ZZStrategyNavigationLeftRight new];
        } break;
            
        case ZZEnvelopObserveType:
        {
            strategy = [ZZEnvelopStrategy new];
        } break;
    }
    
    return strategy;
}

- (void)_startObserveWithWindow:(UIWindow*)window
{
    [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
        for (id event in touches)
        {
            NSSet* touches = [event allTouches];
            UITouch* touch = [touches anyObject];
            [self.touchController observeTouch:touch withEvent:event];
        };
    }];
}

@end

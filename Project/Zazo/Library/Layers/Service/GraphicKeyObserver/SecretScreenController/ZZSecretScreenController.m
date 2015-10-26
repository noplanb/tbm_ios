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

static CGFloat const kDefaultTouchDelay = 0.2;

@interface ZZSecretScreenController ()

@property (nonatomic, strong) ZZBaseTouchController* touchController;
@property (nonatomic, strong) CMMotionManager* motionManager;

@end

@implementation ZZSecretScreenController

+ (void)startObserveWithType:(ZZSecretScreenObserveType)observeType
                   touchType:(ZZSecretScreenTouchType)touchType
                      window:(UIWindow*)window
             completionBlock:(void(^)())completionBlock
{
    ZZSecretScreenController* secretController = [ZZSecretScreenController new];
    
    secretController.touchController = [secretController _touchControllerWithType:touchType
                                                                      observeType:observeType
                                                                  completionBlock:completionBlock];
    
//    secretController.motionManager = [[CMMotionManager alloc] init];
//    secretController.motionManager.deviceMotionUpdateInterval = .1;
//    [secretController.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//        CGFloat accelerationValue = 5;
//        CMAcceleration userAcceleration = motion.userAcceleration;
//        if (fabs(userAcceleration.x) > accelerationValue)
//        {
//            ANDispatchBlockToMainQueue(^{
//                if (completionBlock)
//                {
//                    completionBlock();
//                }
//            });
//        }
//    }];
    
//#ifdef AD-HOC
//    
//#else
    
    [secretController _startObserveWithWindow:window];
    
//#endif
    

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
        }break;
        case ZZSecretScreenTouchTypeWithoutDelay:
        {
            touchController = [[ZZTouchControllerWithoutDelay alloc] initWithStrategy:[self _strategyWithType:observeType]
                                                                  withCompletionBlock:completionBlock];
        
        }break;
        case ZZSecretScreenTouchTypeWithDelay:
        {
            touchController = [[ZZTouchControllerWithTouchDelay alloc] initWithDelay:kDefaultTouchDelay
                                                                        withStrategy:[self _strategyWithType:observeType]
                                                                 withCompletionBlock:completionBlock];
        }break;
 
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
            
        default: break;
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

//
//  ZZRootWireframe.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRootWireframe.h"
#import "ANDebugVC.h"
#import "ZZAuthWireframe.h"
#import "ZZSecretWireframe.h"
#import "ZZSecretScreenObserveTypes.h"
#import "ZZBaseTouchController.h"

//TODO: to remove
#import "ZZTouchControllerWithoutDelay.h"
#import "ZZStrategyNavigationLeftRight.h"
#import "ZZEnvelopStrategy.h"
#import "ZZStartWireframe.h"

@interface ZZRootWireframe ()

@property (nonatomic, strong) ZZBaseTouchController* touchController;

@end

@implementation ZZRootWireframe

- (void)showStartViewControllerInWindow:(UIWindow*)window
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    window.backgroundColor = [UIColor whiteColor];
    
#ifdef DEBUG_CONTROLLER
    UIViewController* vc = [ANDebugVC new];
    [self showRootController:vc inWindow:window];
#else
    ZZStartWireframe* wireframe = [ZZStartWireframe new];
    [wireframe presentStartControllerFromWindow:window];
    
#endif
    
    [self _startSecretScreenObserveWithType:ZZEnvelopObserveType withWindow:window];
}

- (void)showRootController:(UIViewController*)vc inWindow:(UIWindow *)window
{
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
}


#pragma mark - Graphic Key Observer

- (void)_startSecretScreenObserveWithType:(ZZSecretScreenObserveType)type withWindow:(UIWindow*)window
{
    self.touchController = [[ZZTouchControllerWithoutDelay alloc] initWithStrategy:[self _strategyWithType:type]
                                                               withCompletionBlock:^{
        [self _presentSecretScreenFromNavigationController:(UINavigationController*)window.rootViewController];
    }];
    [self _startObserveWithWindow:window];
}

//TODO: move this inside Graphic key Observer class
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

- (void)_presentSecretScreenFromNavigationController:(UINavigationController*)nc
{
    ZZSecretWireframe* wireframe = [ZZSecretWireframe new];
    [wireframe presentSecretControllerFromNavigationController:nc];
}



#pragma mark - Private


@end

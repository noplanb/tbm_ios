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
#import "TBMRegisterViewController.h"
#import "TBMHomeViewController.h"
#import "TBMUser.h"
#import "TBMS3CredentialsManager.h"
#import "TBMAppDelegate+Boot.h" // temp
#import "ZZTouchControllerWithoutDelay.h"
#import "ZZStrategyNavigationLeftRight.h"
#import "ZZEnvelopStrategy.h"
#import "TBMEventsFlowModulePresenter.h"

@interface ZZRootWireframe () <TBMRegisterViewControllerDelegate> // TODO: temp

@property (nonatomic, strong) TBMEventsFlowModulePresenter *eventFlowSystem;
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
//    ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
//    [wireframe presentAuthControllerFromWindow:window];
    
    TBMUser *user = [TBMUser getUser];
    UIViewController* vc;
    if (!user.isRegistered)
    {
        TBMRegisterViewController* registrationVC = [TBMRegisterViewController new];
        registrationVC.delegate = self; // TODO: temp
        vc = registrationVC;
    }
    else
    {
        TBMHomeViewController* homeVC = [TBMHomeViewController new];
        [self.eventFlowSystem setupHandlers];
        vc = homeVC;
        [self postRegistrationBoot];
    }
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.navigationBarHidden = YES;
    window.rootViewController = nc;
    
#endif
    
    [self _startSecretScreenObserveWithType:ZZEnvelopObserveType withWindow:window];
}

- (void)showRootController:(UIViewController*)vc inWindow:(UIWindow *)window
{
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
}


#pragma mark - Old // TODO:

- (void)registrationControllerDidCompleteRegistration:(TBMRegisterViewController *)controller
{
    TBMHomeViewController* vc = [TBMHomeViewController new];
    [self.eventFlowSystem setupHandlers];
    
    [controller presentViewController:vc animated:YES completion:nil];
    [(TBMAppDelegate*)[UIApplication sharedApplication].delegate performDidBecomeActiveActions];
}

- (void)postRegistrationBoot
{
    [TBMS3CredentialsManager refreshFromServer:nil];
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

- (TBMEventsFlowModulePresenter *)eventFlowSystem
{
    if (!_eventFlowSystem)
    {
        _eventFlowSystem = [TBMEventsFlowModulePresenter new];
        //TODO: Event Flow needs to setup gridModule
    }
    return _eventFlowSystem;
}


#pragma mark - Private


@end

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
#import "ZZSecretScreenWireframe.h"

@implementation ZZRootWireframe

- (void)showStartViewControllerInWindow:(UIWindow*)window
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    window.backgroundColor = [UIColor whiteColor];
   ZZSecretScreenWireframe* secretScreenWireframe = [ZZSecretScreenWireframe new];
    [secretScreenWireframe startSecretScreenObserveWithType:ZZNavigationBarLeftRightObserveType withWindow:window];
    
#ifdef DEBUG_CONTROLLER
    UIViewController* vc = [ANDebugVC new];
    [self showRootController:vc inWindow:window];
#else
    ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
    [wireframe presentAuthControllerFromWindow:window];
#endif
    
}

- (void)showRootController:(UIViewController*)vc inWindow:(UIWindow *)window
{
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
//    [wireframe startSecretScreenObservingWithFirstTouchDelay:2 WithType:ZZNavigationBarLeftRightObserveType withWindow:window];
}

@end

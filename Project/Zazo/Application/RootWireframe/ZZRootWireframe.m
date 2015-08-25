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
//TODO: to remove
#import "TBMRegisterViewController.h"
#import "TBMHomeViewController.h"
#import "TBMDependencies.h"
#import "TBMUser.h"
#import "TBMS3CredentialsManager.h"
#import "TBMAppDelegate+Boot.h" // temp

@interface ZZRootWireframe () <TBMRegisterViewControllerDelegate> // TODO: temp

@property (nonatomic, strong) TBMDependencies* dependencies;

@end

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
//    ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
//    [wireframe presentAuthControllerFromWindow:window];
    
    TBMUser *user = [TBMUser getUser];
    if (!user.isRegistered)
    {
        TBMRegisterViewController* vc = [TBMRegisterViewController new];
        vc.delegate = self; // TODO: temp
        window.rootViewController = vc;
    }
    else
    {
        TBMHomeViewController* vc = [TBMHomeViewController new];
        [self.dependencies setupDependenciesWithHomeViewController:vc];
        window.rootViewController = vc;
        [self postRegistrationBoot];
    }
    
#endif
    
}

- (void)showRootController:(UIViewController*)vc inWindow:(UIWindow *)window
{
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
//    [wireframe startSecretScreenObservingWithFirstTouchDelay:2 WithType:ZZNavigationBarLeftRightObserveType withWindow:window];
}


#pragma mark - Old

- (void)registrationControllerDidCompleteRegistration:(TBMRegisterViewController *)controller
{
    TBMHomeViewController* vc = [TBMHomeViewController new];
    [self.dependencies setupDependenciesWithHomeViewController:vc];
    
    [controller presentViewController:vc animated:YES completion:nil];
    [(TBMAppDelegate*)[UIApplication sharedApplication].delegate performDidBecomeActiveActions];
}

- (void)postRegistrationBoot
{
    [TBMS3CredentialsManager refreshFromServer:nil];
}

- (TBMDependencies *)dependecies
{
    if (!_dependencies)
    {
        _dependencies = [[TBMDependencies alloc] init];
    }
    return _dependencies;
}

@end

//
//  ZZAppDependencies.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAppDependencies.h"
#import "ZZRootWireframe.h"
#import "ANAppColorTheme.h"
#import "ZZAppDependecesInjection.h"

@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe* rootWireframe;

@end

@implementation ZZAppDependencies

- (void)installRootViewControllerIntoWindow:(UIWindow *)window
{
    [self.rootWireframe showStartViewControllerInWindow:window];
}

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary *)options
{
    [ANAppColorTheme shared];
}

- (BOOL)handleOpenURL:(NSURL*)url inApplication:(NSString*)application
{
    return NO;
}

- (void)handleApplicationDidBecomeActive
{
    
}

- (void)handleApplicationWillTerminate
{

}

- (void)installAppDependences
{
    
}

#pragma mark - Push

- (void)handleApplicationDidRegisterForPushWithToken:(NSData *)token
{
    ZZAppDependecesInjection* injection = [ZZAppDependecesInjection new];
    [injection configureTyphoon];
}

- (void)handleApplication:(UIApplication *)application didRecievePushNotification:(NSDictionary *)userInfo
{

}

- (void)handleApplication:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{

}


#pragma mark - Private

- (ZZRootWireframe *)rootWireframe
{
    if (!_rootWireframe)
    {
        _rootWireframe = [ZZRootWireframe new];
    }
    return _rootWireframe;
}

@end

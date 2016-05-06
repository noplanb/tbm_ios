//
//  ANAppDelegate.m
//  Zazo
//
//  Created by ANODA on 4/27/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAppDelegate.h"
#import "ZZAppDependencies.h"

@interface ZZAppDelegate ()

@property (nonatomic, strong) ZZAppDependencies *appDependencies;

@end

@implementation ZZAppDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.appDependencies initialApplicationSetup:app launchOptions:launchOptions window:self.window];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)app
{
    [self.appDependencies handleWillResignActive];
    ZZLogInfo(@"applicationWillResignActive");
}

- (void)applicationWillEnterForeground:(UIApplication *)app
{
    [self.appDependencies handleApplicationWillEnterForeground];
    ZZLogInfo(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)app
{
    ZZLogInfo(@"applicationDidBecomeActive");
    [self.appDependencies handleApplicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)app
{
    ZZLogInfo(@"applicationWillTerminate: backgroundTimeRemaining = %f",
            [[UIApplication sharedApplication] backgroundTimeRemaining]);

    [self.appDependencies handleApplicationWillTerminate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.appDependencies handleApplicationDidEnterInBackground];
}


#pragma mark - Background

- (void)application:(UIApplication *)app handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    [self.appDependencies handleBackgroundSessionWithIdentifier:identifier completionHandler:completionHandler];
}


#pragma mark - Notifications

- (void)   application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    [self.appDependencies handlePushNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)app didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    [self.appDependencies handleNotificationSettings:settings];
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.appDependencies handleApplicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.appDependencies handleApplicationDidRegisterForPushWithToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.appDependencies handlePushNotification:userInfo];
}


#pragma mark - External

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [self.appDependencies handleOpenURL:url inApplication:sourceApplication];
}


#pragma mark - Private

- (ZZAppDependencies *)appDependencies
{
    if (!_appDependencies)
    {
        _appDependencies = [ZZAppDependencies new];
    }
    return _appDependencies;
}

@end

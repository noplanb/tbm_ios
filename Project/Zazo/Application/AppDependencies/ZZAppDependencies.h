//
//  ZZAppDependencies.h
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAppDependencies : NSObject

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary*)options;

- (void)handleWillResignActive;
- (BOOL)handleOpenURL:(NSURL*)url inApplication:(NSString*)application;
- (void)handleApplicationDidBecomeActive;
- (void)handleApplicationWillTerminate;
- (void)handleApplicationDidEnterInBackground;

- (void)handleApplicationDidRegisterForPushWithToken:(NSData*)token;
- (void)handleApplication:(UIApplication*)application didRecievePushNotification:(NSDictionary*)userInfo;

- (void)handleApplication:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

- (void)installRootViewControllerIntoWindow:(UIWindow *)window;
- (void)installAppDependences;

@end

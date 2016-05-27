//
//  ZZAppDependencies.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import CoreTelephony;

#import "ZZAppDependencies.h"
#import "ZZRootWireframe.h"
#import "ANCrashlyticsAdapter.h"
#import "ZZContentDataAccessor.h"
#import "ZZRollbarAdapter.h"
#import "ZZNotificationsHandler.h"
#import "ZZApplicationRootService.h"
#import "ZZGridActionStoredSettings.h"
#import "OBLogger+ZZAdditions.h"
#import "ZZCacheCleaner.h"

@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe *rootWireframe;
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) ZZNotificationsHandler *notificationsHandler;
@property (nonatomic, strong) ZZApplicationRootService *rootService;

@property (nonatomic, assign) BOOL initialisationCompleted;

@end

@implementation ZZAppDependencies

- (void)initialApplicationSetup:(UIApplication *)application
                  launchOptions:(NSDictionary *)options
                         window:(UIWindow *)window
{
    [ANCrashlyticsAdapter start];
    [ZZContentDataAccessor startWithCompletionBlock:^{
        [ZZRollbarAdapter shared];

        [self _logAppLaunch];

        [ZZCacheCleaner cleanIfNeeded];

        ANDispatchBlockToBackgroundQueue(^{
            [ZZColorTheme shared];
        });

        [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelError];

        self.notificationsHandler = [ZZNotificationsHandler new];
        self.rootService = [ZZApplicationRootService new];

        self.notificationsHandler.delegate = self.rootService;
        self.rootService.notificationDelegate = (id)self.notificationsHandler;

        NSDictionary *remoteNotification = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification)
        {
            [self handlePushNotification:remoteNotification];
        }
        [self installRootViewControllerIntoWindow:window];
    }];
}

- (void)_logAppLaunch
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];

    NSString *appName = bundleInfo[@"CFBundleDisplayName"];
    NSString *appVersion = bundleInfo[@"CFBundleShortVersionString"];
    NSString *bundleVersion = bundleInfo[@"CFBundleVersion"];

    ZZLogInfo(@"App launch: %@ %@ (%@)", appName, appVersion, bundleVersion);
}

#pragma mark - Application States

- (void)handleWillResignActive
{
    [self.rootService updateBadgeCounter];
}

- (void)handleApplicationDidBecomeActive
{
    ZZLogEvent(@"APP ENTERED FOREGROUND");

    if (self.initialisationCompleted)
    {
        [self.rootService checkApplicationPermissionsAndResources];
    }

    [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = NO;
}

- (void)handleApplicationWillEnterForeground
{

}

- (void)handleApplicationWillTerminate
{
    [ZZContentDataAccessor saveDataBase];
    [[OBLogger instance] dropOldLines:2000];
}

- (void)handleApplicationDidEnterInBackground
{
    ZZLogInfo(@"applicationDidEnterBackground: backgroundTimeRemaining = %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    [ZZContentDataAccessor saveDataBase];
    ZZLogEvent(@"APP ENTERED BACKGROUND");
}


#pragma mark - UI 

- (void)installRootViewControllerIntoWindow:(UIWindow *)window
{
    [self.rootWireframe showStartViewControllerInWindow:window completionBlock:^{
        self.initialisationCompleted = YES;

        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
        {
            [self.rootService checkApplicationPermissionsAndResources];
        }
    }];
}


#pragma mark - External URL

- (BOOL)handleOpenURL:(NSURL *)url inApplication:(NSString *)application
{
    return NO;
}


#pragma mark - Background Session

- (void)handleBackgroundSessionWithIdentifier:(NSString *)identifier completionHandler:(ANCodeBlock)completionHandler
{
    [self.rootService handleBackgroundSessionWithIdentifier:identifier completionHandler:completionHandler];
}


#pragma mark - Push

- (void)handleApplicationDidRegisterForPushWithToken:(NSData *)token
{
    [self.notificationsHandler receivedPushNotificationsToken:token];
}

- (void)handlePushNotification:(NSDictionary *)userInfo
{
    [self.notificationsHandler handlePushNotification:userInfo];
}

- (void)handleNotificationSettings:(UIUserNotificationSettings *)settings
{
    [self.notificationsHandler applicationRegisteredWithSettings:settings];
}

- (void)handleApplicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.notificationsHandler applicationDidFailToRegisterWithError:error];
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

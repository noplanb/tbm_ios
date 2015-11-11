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
#import "ZZContentDataAcessor.h"
#import "ZZVideoRecorder.h"
#import "ZZUserDataProvider.h"
#import "ZZRollbarAdapter.h"
#import "ZZNotificationsHandler.h"
#import "ZZApplicationRootService.h"
#import "ZZGridActionStoredSettings.h"

@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe* rootWireframe;
@property (nonatomic, strong) CTCallCenter* callCenter;
@property (nonatomic, strong) ZZNotificationsHandler* notificationsHandler;
@property (nonatomic, strong) ZZApplicationRootService* rootService;

@end

@implementation ZZAppDependencies

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.notificationsHandler = [ZZNotificationsHandler new];
        self.rootService = [ZZApplicationRootService new];
        
        self.notificationsHandler.delegate = self.rootService;
        self.rootService.notificationDelegate = (id)self.notificationsHandler;
    }
    return self;
}

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary *)options
{
    [ZZRollbarAdapter shared];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
    [ZZContentDataAcessor start];
    
    NSDictionary *remoteNotification = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification)
    {
        [self handlePushNotification:remoteNotification];
    }
    
    ANDispatchBlockToBackgroundQueue(^{
        [ANCrashlyticsAdapter start];
        [ANLogger initializeLogger];
        [ZZColorTheme shared];
        [self _handleIncomingCall];
    });
}


#pragma mark - Application States

- (void)handleWillResignActive
{
    ANDispatchBlockToBackgroundQueue(^{
       
        ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
        if (user.isRegistered)
        {
            ANDispatchBlockToMainQueue(^{
            });
        }
    });
    
    [self.rootService updateBadgeCounter];
}

- (void)handleApplicationDidBecomeActive
{
    [[OBLogger instance] logEvent:OBLogEventAppForeground];
//    [self.rootService checkApplicationPermissionsAndResources];
    [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = NO;
}

- (void)handleApplicationWillEnterForeground
{
  
}

- (void)handleApplicationWillTerminate
{
    [ZZContentDataAcessor saveDataBase];
}

- (void)handleApplicationDidEnterInBackground
{
    ZZLogInfo(@"applicationDidEnterBackground: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    [ZZContentDataAcessor saveDataBase];
    [[OBLogger instance] logEvent:OBLogEventAppBackground];
}


#pragma mark - UI 

- (void)installRootViewControllerIntoWindow:(UIWindow *)window
{
    [self.rootWireframe showStartViewControllerInWindow:window completionBlock:^{
        [self.rootService checkApplicationPermissionsAndResources];
    }];
}


#pragma mark - External URL

- (BOOL)handleOpenURL:(NSURL*)url inApplication:(NSString*)application
{
    return NO;
}


#pragma mark - Background Session

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler
{
    [self.rootService handleBackgroundSessionWithIdentifier:identifier completionHandler:completionHandler];
}


#pragma mark - Push

- (void)handleApplicationDidRegisterForPushWithToken:(NSData*)token
{
    [self.notificationsHandler receivedPushNotificationsToken:token];
}

- (void)handlePushNotification:(NSDictionary *)userInfo
{
    [self.notificationsHandler handlePushNotification:userInfo];
}

- (void)handleNotificationSettings:(UIUserNotificationSettings*)settings
{
    [self.notificationsHandler applicationRegisteredWithSettings:settings];
}

- (void)handleApplicationDidFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [self.notificationsHandler applicationDidFailToRegisterWithError:error];
}


#pragma mark - Private

- (void)_handleIncomingCall
{
    self.callCenter = [[CTCallCenter alloc] init];
    [self.callCenter setCallEventHandler:^(CTCall * call) {
        if ([call.callState isEqualToString:CTCallStateIncoming])
        {
            ANDispatchBlockToMainQueue(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIncomingCall object:nil];
            });
        }
    }];
}

- (ZZRootWireframe*)rootWireframe
{
    if (!_rootWireframe)
    {
        _rootWireframe = [ZZRootWireframe new];
    }
    return _rootWireframe;
}

@end

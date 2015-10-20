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
#import "ZZColorTheme.h"
#import "ANCrashlyticsAdapter.h"
#import "ZZContentDataAcessor.h"
#import "ZZVideoRecorder.h"
#import "ANLogger.h"
#import "MagicalRecord.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"
#import "ZZRollbarAdapter.h"
#import "ZZNotificationsHandler.h"

@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe* rootWireframe;
@property (nonatomic, strong) CTCallCenter* callCenter;
@property (nonatomic, strong) ZZNotificationsHandler* notificationsHandler;

@end

@implementation ZZAppDependencies

- (void)installRootViewControllerIntoWindow:(UIWindow *)window
{
    [self.rootWireframe showStartViewControllerInWindow:window];
}

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary *)options
{
    [ZZRollbarAdapter shared];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
    [ZZContentDataAcessor start];
    
    ANDispatchBlockToBackgroundQueue(^{
        [ANCrashlyticsAdapter start];
        [ANLogger initializeLogger];
        [ZZColorTheme shared];
        [self _handleIncomingCall];
        
        self.notificationsHandler = [ZZNotificationsHandler new];
    });
}

- (void)handleWillResignActive
{
    ANDispatchBlockToBackgroundQueue(^{
       
        ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
        if (user.isRegistered)
        {
            ANDispatchBlockToMainQueue(^{
                [self _handleResignActive];
            });
        }
    });
}

- (BOOL)handleOpenURL:(NSURL*)url inApplication:(NSString*)application
{
    return NO;
}

- (void)handleApplicationDidBecomeActive
{
    ANDispatchBlockToBackgroundQueue(^{
        ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
        if (user.isRegistered)
        {
            ANDispatchBlockToMainQueue(^{
               [[ZZVideoRecorder shared] updateRecorder];
            });
        }
    });
    
    [[OBLogger instance] logEvent:OBLogEventAppForeground];
}

- (void)handleApplicationWillTerminate
{
    [ZZContentDataAcessor saveDataBase];
}

- (void)installAppDependences
{
    
}

- (void)handleApplicationDidEnterInBackground
{
    OB_INFO(@"applicationDidEnterBackground: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    [ZZContentDataAcessor saveDataBase];
    [[OBLogger instance] logEvent:OBLogEventAppBackground];
}


#pragma mark - Push

- (void)handleApplicationDidRegisterForPushWithToken:(NSData*)token
{
    [self.notificationsHandler receivedPushNotificationsToken:token];
}

- (void)handleApplication:(UIApplication *)application didRecievePushNotification:(NSDictionary *)userInfo
{
    [self.notificationsHandler handlePushNotification:userInfo];
}

- (void)handleApplication:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [self.notificationsHandler applicationRegisteredWithSettings:notificationSettings];
}

- (void)handleApplicationDidFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [self.notificationsHandler applicationDidFailToRegisterWithError:error];
}


#pragma mark - Private

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ZZRootWireframe *)rootWireframe
{
    if (!_rootWireframe)
    {
        _rootWireframe = [ZZRootWireframe new];
    }
    return _rootWireframe;
}

- (void)_handleIncomingCall
{
    self.callCenter = [[CTCallCenter alloc] init];
    [self.callCenter setCallEventHandler:^(CTCall * call) {
        if ([call.callState isEqualToString:CTCallStateIncoming])
        {
            ANDispatchBlockToMainQueue(^{
                [[ZZVideoRecorder shared] cancelRecordingWithReason:NSLocalizedString(@"record-canceled-reason-incoming-call", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIncomingCall object:nil];
            });
        }
    }];
}

- (void)_handleResignActive
{
    [[ZZVideoRecorder shared] stopAudioSession];
    [[ZZVideoRecorder shared] cancelRecording];
}

@end

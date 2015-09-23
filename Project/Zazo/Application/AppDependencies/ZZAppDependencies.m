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


@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe* rootWireframe;
@property (nonatomic, strong) CTCallCenter* callCenter;
@end

@implementation ZZAppDependencies

- (void)installRootViewControllerIntoWindow:(UIWindow *)window
{
    [self.rootWireframe showStartViewControllerInWindow:window];
}

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary *)options
{
    [ANCrashlyticsAdapter start];
    [ANLogger initializeLogger];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
    [ZZContentDataAcessor start];
    [ZZVideoRecorder shared];
    [ZZColorTheme shared];
    [self _handleIncomingCall];
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
    [ZZContentDataAcessor saveDataBase];
}

- (void)installAppDependences
{
    
}

- (void)handleApplicationDidEnterInBackground
{
    [ZZContentDataAcessor saveDataBase];
}

#pragma mark - Push

- (void)handleApplicationDidRegisterForPushWithToken:(NSData *)token
{

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

- (void)_handleIncomingCall
{
    self.callCenter = [[CTCallCenter alloc] init];
    [self.callCenter setCallEventHandler:^(CTCall * call) {
        if ([call.callState isEqualToString:CTCallStateIncoming])
        {
            ANDispatchBlockToMainQueue(^{
                [[ZZVideoRecorder shared] cancelRecordingWithReason:NSLocalizedString(@"record-canceled-reason-incoming-call", nil)];
            });
        }
    }];
}

@end

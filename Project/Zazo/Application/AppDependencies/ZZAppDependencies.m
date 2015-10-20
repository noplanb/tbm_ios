//
//  ZZAppDependencies.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

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
    [ZZRollbarAdapter shared];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
    [ZZContentDataAcessor start];
    
    ANDispatchBlockToBackgroundQueue(^{
        [ANCrashlyticsAdapter start];
        [ANLogger initializeLogger];
        [ZZColorTheme shared];
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

- (void)_handleResignActive
{
    [[ZZVideoRecorder shared] stopAudioSession];
    [[ZZVideoRecorder shared] cancelRecording];
}

@end

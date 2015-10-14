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
#import "ZZCoreTelephonyConstants.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"
#import "OBLoggerNotification.h"
#import <Crashlytics/Crashlytics.h>

#warning REMOVE AFTER OBLOGGER UPDATED
#define OBLoggerEventNotification @"OBLoggerEventNotification"
#define OBLoggerInfoNotification @"OBLoggerInfoNotification"
#define OBLoggerDebugNotification @"OBLoggerDebugNotification"

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
    // Setup listening log notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logEvent:) name:OBLoggerEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logError:) name:OBLoggerErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logWarn:) name:OBLoggerWarnNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logInfo:) name:OBLoggerInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logDebug:) name:OBLoggerDebugNotification object:nil];

    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
    [ZZContentDataAcessor start];
    ANDispatchBlockToBackgroundQueue(^{
        [ANCrashlyticsAdapter start];
        [ANLogger initializeLogger];
        [ZZColorTheme shared];
        [self _handleIncomingCall];
    });
}

- (void)_logDebug:(NSNotification*)notification
{
    [self _log:@" DEBUG " message:notification];
}

- (void)_logInfo:(NSNotification*)notification
{
    [self _log:@" INFO " message:notification];
}

- (void)_logWarn:(NSNotification*)notification
{
    [self _log:@" WARN " message:notification];
}

- (void)_logError:(NSNotification*)notification
{
    [self _log:@" ERROR " message:notification];
}

- (void)_logEvent:(NSNotification*)notification
{
    [self _log:@" EVENT " message:notification];
}

- (void)_log:(NSString*)prefix message:(NSNotification*)notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        NSString* message = notification.object;
        CLS_LOG(@"[%@] : %@",prefix,message);
    }
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

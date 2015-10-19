//
//  TBMAppDelegate.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"
#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "OBFileTransferManager.h"
#import "TBMUser.h"
#import "AVAudioSession+TBMAudioSession.h"
#import "ZZAppDependencies.h"
#import "ZZContentDataAcessor.h"
#import "ZZVideoRecorder.h"

#import "ZZGridActionStoredSettings.h"

@interface TBMAppDelegate()

@property (nonatomic, copy) void (^registredToNotifications)(void);

@end

@implementation TBMAppDelegate

#pragma mark - Lifecycle callbacks

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.appDependencies initialApplicationSetup:application launchOptions:launchOptions];
    
    self.pushAlreadyFailed = NO;
    [self addObservers];
    
    OB_INFO(@"didFinishLaunchingWithOptions:");
    
    
    [self.window makeKeyAndVisible];
    [self.appDependencies installRootViewControllerIntoWindow:self.window];
    
    [self boot];

    // See doc/notification.txt for why we handle the payload here as well as in didReceiveRemoteNotification:fetchCompletionHandler
    // for the case where app is launching from a terminated state due to user clicking on notification. Even though both this method
    // and the didReceiveRemoteNotification:fetchCompletionHandler are called in that case.
    NSDictionary *remoteNotificationUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationUserInfo){
        [self requestBackground];
        [self handleNotificationPayload:remoteNotificationUserInfo];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.appDependencies handleWillResignActive];
    OB_INFO(@"applicationWillResignActive");
    [self setBadgeNumberDownloadedUnviewed];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    OB_INFO(@"applicationDidEnterBackground: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    self.isForeground = NO;
    [self.appDependencies handleApplicationDidEnterInBackground];
    [[OBLogger instance] logEvent:OBLogEventAppBackground];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    
    [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = NO;
    
    OB_INFO(@"applicationWillEnterForeground");
    self.isForeground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    OB_INFO(@"applicationDidBecomeActive");
    [self.appDependencies handleApplicationDidBecomeActive];
    self.isForeground = YES;
    
    ANDispatchBlockToBackgroundQueue(^{
       [self performDidBecomeActiveActions];
    });
    [[OBLogger instance] logEvent:OBLogEventAppForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    OB_INFO(@"applicationWillTerminate: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    // Saves changes in the application's managed object context before the application terminates.
    [self.appDependencies handleApplicationWillTerminate];
    [self removeObservers];
}


#pragma mark - Notification Observers

- (void)addObservers{
    [self addVideoProcessorObservers];
    [self addVideoRecordingObservers];
    
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//----------------------------------
// Background URL Session Completion
//----------------------------------
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    OB_INFO(@"handleEventsForBackgroundURLSession: for sessionId=%@",identifier);
    OBFileTransferManager *tm = [OBFileTransferManager instance];
    if ([[tm session].configuration.identifier isEqual:identifier]){
        tm.backgroundSessionCompletionHandler = completionHandler;
    } else {
        OB_ERROR(@"handleEventsForBakcgroundURLSession passed us a different identifier from the one we instantiated our background session with.");
    }
}

//-------------------
// Request Background
//-------------------
-(void) requestBackground{
    OB_INFO(@"AppDelegate: requestBackground: called:");
    if ( self.backgroundTaskId == UIBackgroundTaskInvalid ) {
        OB_INFO(@"AppDelegate: requestBackground: requesting background.");
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            OB_INFO(@"AppDelegate: Ending background");
            // The apple docs say you must terminate the background task you requested when they call the expiration handler
            // or before or they will terminate your app. I have found however that if I dont terminate and if
            // the usage of the phone is low by other apps they will let us run in the background indefinitely
            // even after the backgroundTimeRemaining has long gone to 0. This is good for our users as it allows us
            // to continue retries in the background for a long time in the case of poor coverage.
            
            // Actually on iphone4s 7.0 I encountered this:
            // Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Zazo[272] has active assertions beyond permitted time:
            //            {(
            //              <BKProcessAssertion: 0x15ebf2a0> identifier: Called by Zazo, from -[TBMAppDelegate requestBackground] process: Zazo[272] permittedBackgroundDuration: 40.000000 reason: finishTaskAfterBackgroundContentFetching owner pid:272 preventSuspend  preventIdleSleep  preventSuspendOnSleep
            //              )}
            //            Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Forcing crash report of Zazo[272]...
            
        
            // So as of 2/19/2005 I have uncommented the line below.
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskId];
            [ZZContentDataAcessor saveDataBase];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }];
    }
    OB_INFO(@"AppDelegate: RequestBackground: exiting: refresh status = %ld, time Remaining = %f", (long)[UIApplication sharedApplication].backgroundRefreshStatus, [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)onGrantedPushAccess
{
    [self _onGrantedPushAccess];
}

- (void)onFailPushAccess
{
    [self _onFailPushAccess];
}


#pragma mark - Lazy Load

- (UIWindow*)window
{
    if (!_window)
    {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _window;
}

- (ZZAppDependencies*)appDependencies
{
    if (!_appDependencies)
    {
        _appDependencies = [ZZAppDependencies new];
    }
    return _appDependencies;
}

@end

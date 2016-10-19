//
//  ZZAppDependencies.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import CoreTelephony;

#import "ZZAppDependencies.h"
#import "ANCrashlyticsAdapter.h"
#import "ZZContentDataAccessor.h"
#import "ZZRollbarAdapter.h"
#import "ZZNotificationsHandler.h"
#import "ZZApplicationRootService.h"
#import "ZZGridActionStoredSettings.h"
#import "OBLogger+ZZAdditions.h"
#import "ZZCacheCleaner.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendDataProvider.h"

#import "ZZRootWireframe.h"
#import "ZZStartWireframe.h"
#import "ZZGridWireframe.h"
#import "ZZContactsWireframe.h"
#import "ZZMenuWireframe.h"
#import "ZZMainWireframe.h"

@interface ZZAppDependencies ()

@property (nonatomic, strong) ZZRootWireframe *rootWireframe;
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) ZZNotificationsHandler *notificationsHandler;
@property (nonatomic, strong) ZZApplicationRootService *rootService;
@property (nonatomic, strong) NotificationActionHandler *notificationActionHandler;

@property (nonatomic, assign) BOOL initializationCompleted;
@property (nonatomic, strong) NSString *shouldShowComposeForUserID;
@property (nonatomic, assign) BOOL isLaunchFromNotification;

@end

@implementation ZZAppDependencies

- (void)initialApplicationSetup:(UIApplication *)application
                  launchOptions:(NSDictionary *)options
                         window:(UIWindow *)window
{
    [ANCrashlyticsAdapter start];
    [ZZRollbarAdapter shared];
    
    [ZZContentDataAccessor startWithCompletionBlock:^{

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
        self.notificationActionHandler = [NotificationActionHandler new];
        
        [self.notificationActionHandler register:ZZMessageTextActionIdentifier handler:^(NSDictionary<NSString *,id> * _Nonnull userData) {
            [self handleTextActionWithUserData:userData];
            [self showComposeScreenIfNeeded];
        }];
        
        NSDictionary *remoteNotification = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification)
        {
            [self handlePushNotification:remoteNotification isLaunch:NO];
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

    if (self.initializationCompleted)
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
        self.initializationCompleted = YES;

        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
        {
            [self.rootService checkApplicationPermissionsAndResources];
            [self showComposeScreenIfNeeded];
            [self playVideoIfNeeded];
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

- (void)handlePushNotification:(NSDictionary *)userInfo isLaunch:(BOOL)flag
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

- (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)userInfo
                  withResponseInfo:(NSDictionary *)responseInfo
                 completionHandler:(void (^)())completionHandler
{
    [self.notificationActionHandler handle:identifier userInfo:userInfo];
    completionHandler();
}

#pragma mark - Private

- (ZZRootWireframe *)rootWireframe
{
    if (!_rootWireframe)
    {
        _rootWireframe = [ZZRootWireframe new];

        ZZStartWireframe *startWireframe = [ZZStartWireframe new];
        _rootWireframe.startWireframe = startWireframe;
        
        ZZMainWireframe *mainWireframe = [ZZMainWireframe new];
        startWireframe.mainWireframe = mainWireframe;
        
        ZZGridWireframe *gridWireframe = [ZZGridWireframe new];
        ZZContactsWireframe *contactsWireframe = [ZZContactsWireframe new];
        ZZMenuWireframe *menuWireframe = [ZZMenuWireframe new];
        
        gridWireframe.mainWireframe = mainWireframe;
        contactsWireframe.mainWireframe = mainWireframe;
        menuWireframe.mainWireframe = mainWireframe;

        mainWireframe.gridWireframe = gridWireframe;
        mainWireframe.contactsWireframe = contactsWireframe;
        mainWireframe.menuWireframe = menuWireframe;
    }
    return _rootWireframe;
}

- (void)handleTextActionWithUserData:(NSDictionary *)userData {
    
    FEMObjectMapping *mapping = ZZMessageNotificationDomainModel.mapping;
    ZZMessageNotificationDomainModel *messageModel =
    [FEMObjectDeserializer deserializeObjectExternalRepresentation:userData usingMapping:mapping];
    
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithMKeyValue:messageModel.from_mkey];
    
    if (!friendModel) {
        return;
    }
    
    self.shouldShowComposeForUserID = friendModel.idTbm;
}

- (void)showComposeScreenIfNeeded
{
    
    if (ANIsEmpty(self.shouldShowComposeForUserID))
    {
        return;
    }
    
    if (!self.initializationCompleted)
    {
        return;
    }
    
    [self.rootWireframe.startWireframe.mainWireframe.gridWireframe presentComposeForUserWithID:self.shouldShowComposeForUserID];
}

- (void)playVideoIfNeeded
{
    if (self.notificationsHandler.shouldPlayVideosForUserID == nil)
    {
        return;
    }
}

@end

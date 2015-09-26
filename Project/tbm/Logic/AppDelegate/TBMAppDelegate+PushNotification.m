//
//  TBMAppDelegate+PushNotification.m
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMUser.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"
#import "NSObject+ANSafeValues.h"
#import "ZZStoredSettingsManager.h"
#import "ZZNotificationTransportService.h"
#import "ZZAPIRoutes.h"
#import "ZZFriendDataProvider.h"
#import "ZZSoundPlayer.h"
#import "ZZGlobalHeader.h"

static NSString *NOTIFICATION_TARGET_MKEY_KEY = @"target_mkey";
static NSString *NOTIFICATION_FROM_MKEY_KEY = @"from_mkey";
static NSString *NOTIFICATION_SENDER_NAME_KEY = @"sender_name";
static NSString *NOTIFICATION_VIDEO_ID_KEY = @"video_id";
static NSString *NOTIFICATION_TO_MKEY_KEY = @"to_mkey";
static NSString *NOTIFICATION_STATUS_KEY = @"status";
static NSString *NOTIFICATION_TYPE_KEY = @"type";

static NSString *NOTIFICATION_TYPE_VIDEO_RECEIVED = @"video_received";
static NSString *NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE = @"video_status_update";


@implementation TBMAppDelegate (PushNotification)

#pragma mark -  Setup and registration
- (BOOL)usesIos8PushRegistration{
    return [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
}

- (void)registerForPushNotification {
    OB_INFO(@"registerForPushNotification");
    if ([self usesIos8PushRegistration]) {
        // ios8
        OB_INFO(@"registerForPushNotification: ios8");
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // < ios8
        OB_INFO(@"registerForPushNotification: < ios8");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    UIUserNotificationType allowedTypes = [notificationSettings types];
    OB_INFO(@"didRegisterUserNotificationSettings: allowedTypes = %lu", (unsigned long)allowedTypes);
    self.notificationAllowedTypes = allowedTypes;
    [[UIApplication sharedApplication] registerForRemoteNotifications];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    OB_INFO(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSString *pushToken = [deviceToken description];
    pushToken = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    DebugLog(@"Push token: %@", pushToken);
    
    [self sendPushTokenToServer:pushToken];
    
    if ([self userHasGrantedPushAccess]) {
        [self onGrantedPushAccess];
    } else {
        [self onFailPushAccess];
    };
}


/**
 * Pre IOS8 Idosynracies (IOS7 and lower):
 * User clicks NO when asked the first time:
 *   - AppDelegate never calls didRegisterForRemoteNotificationsWithDeviceToken or didFailToRegisterForRemoteNotificationsWithError
 *   - So we never know that user has denied push notifications
 *
 * User clicks NO then activates them in notification center
 *   - AppDlelegate calls didRegisterForRemoteNotificationsWithDeviceToken
 *   - enabledNotificationTypes returns non zero
 *
 * User clicks YES when asked the first time:
 *   - AppDlelegate calls didRegisterForRemoteNotificationsWithDeviceToken
 *   - enabledNotificationTypes returns non zero
 *
 * User clicks YES then deactivates them in notification center
 *   - AppDelegate never calls didRegisterForRemoteNotificationsWithDeviceToken or didFailToRegisterForRemoteNotificationsWithError
 *   - So we never know that user has denied push notifications.
 *
 * In IOS7 and earlier we never know if user has not granted push access or has revoked it.
 */
- (BOOL)userHasGrantedPushAccess{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        // ios8
        return self.notificationAllowedTypes != UIRemoteNotificationTypeNone;
    } else {
        // ios < 8
        // Note this never gets called in the case user has not granted access in io7 see above. So it is kind of useless.
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    OB_ERROR(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
    [self onFailPushAccess];

}

- (void)sendPushTokenToServer:(NSString *)token
{
    OB_INFO(@"sendPushTokenToServer");
    NSString *myMkey = [ZZUserDataProvider authenticatedUser].mkey;

    [[ZZNotificationTransportService uploadToken:token userMKey:myMkey] subscribeNext:^(id x) {
        
        OB_INFO(@"notification/push_token: SUCCESS %@", x);
    } error:^(NSError *error) {
        OB_WARN(@"notification/push_token: %@", error);
    }];
}

#pragma mark -  Handle Incoming Notifications

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Not used as all of our notification are of type content-available = 1.
    DebugLog(@"didReceiveRemoteNotification");
}

void (^_completionHandler)(UIBackgroundFetchResult);

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    OB_INFO(@"didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
    
    self.pushVideoId = [userInfo objectForKey:@"video_id"];
    [self requestBackground];
    [self handleNotificationPayload:userInfo];
    
    // See doc/notification.txt for why we call the completion handler with sucess immediately here.
//    _completionHandler = [completionHandler copy];
//    [NSTimer scheduledTimerWithTimeInterval:4.0
//                                     target:self
//                                   selector:@selector(callCompletionHandler)
//                                   userInfo:nil
//                                    repeats:NO];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)callCompletionHandler {
    if (_completionHandler != nil) {
        OB_INFO(@"Calling completion handler");
        _completionHandler(UIBackgroundFetchResultNewData);
    } else {
        OB_ERROR(@"Not calling completion handler it was nil");
    }
}

- (void)handleNotificationPayload:(NSDictionary *)userInfo {
    if ([self isVideoReceivedType:userInfo]) {
        [self handleVideoReceivedNotification:userInfo];
    } else if ([self isVideoStatusUpdateType:userInfo]) {
        [self handleVideoStatusUpdateNotification:userInfo];
    } else {
        OB_ERROR(@"handleNotificationPayload: ERROR unknown notification type received");
    }
}

- (NSString *)videoIdWithUserInfo:(NSDictionary *)userInfo {
    return userInfo[NOTIFICATION_VIDEO_ID_KEY];
}

- (BOOL)isVideoReceivedType:(NSDictionary *)userInfo {
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_RECEIVED];
}

- (BOOL)isVideoStatusUpdateType:(NSDictionary *)userInfo {
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE];
}

- (void)handleVideoReceivedNotification:(NSDictionary *)userInfo {
    OB_INFO(@"handleVideoReceivedNotification:");
    NSString *videoId = [self videoIdWithUserInfo:userInfo];
    NSString *mkey = userInfo[NOTIFICATION_FROM_MKEY_KEY];
    TBMFriend *friend = [TBMFriend findWithMkey:mkey];

    if (friend == nil) {
        OB_INFO(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self getAndPollAllFriends];
        return;
    }

    [self queueDownloadWithFriend:friend videoId:videoId];
}

- (void)handleVideoStatusUpdateNotification:(NSDictionary *)userInfo {
    OB_INFO(@"handleVideoStatusUPdateNotification:");
    NSString *nstatus = userInfo[NOTIFICATION_STATUS_KEY];
    NSString *mkey = userInfo[NOTIFICATION_TO_MKEY_KEY];
    TBMFriend *friend = [TBMFriend findWithMkey:mkey];

    if (friend == nil) {
        OB_INFO(@"handleVideoStatusUPdateNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self getAndPollAllFriends];
        return;
    }

    NSString *videoId = [userInfo objectForKey:NOTIFICATION_VIDEO_ID_KEY];

    TBMOutgoingVideoStatus outgoingStatus;
    if ([nstatus isEqual:NOTIFICATION_STATUS_DOWNLOADED])
    {
        outgoingStatus = OUTGOING_VIDEO_STATUS_DOWNLOADED;
    }
    else if ([nstatus isEqual:NOTIFICATION_STATUS_VIEWED])
    {
        outgoingStatus = OUTGOING_VIDEO_STATUS_VIEWED;
    }
    else
    {
        OB_ERROR(@"unknown status received in notification");
        return;
    }

    [friend setAndNotifyOutgoingVideoStatus:outgoingStatus videoId:videoId];
}

#pragma mark -  Notification center and badge control

- (void)clearBadgeCount {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)setBadgeNumberUnviewed {
    OB_INFO(@"setBadgeNumberUnviewed = %lu", (unsigned long) [TBMVideo unviewedCount]);
    [self setBadgeCount:[TBMVideo unviewedCount]];
}

- (void)setBadgeNumberDownloadedUnviewed {
    OB_INFO(@"setBadgeNumberDownloadedUnviewed = %lu", (unsigned long) [TBMVideo downloadedUnviewedCount]);
    [self setBadgeCount:[TBMVideo downloadedUnviewedCount]];
}

- (void)setBadgeCount:(NSInteger)count {
    if (count == 0)
        [self clearBadgeCount];
    else
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}


#pragma mark -  Send outgoing Notifications
- (void)sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    [[ZZNotificationTransportService sendVideoReceivedNotificationTo:friendModel
                                                         videoItemID:videoId
                                                                from:me] subscribeNext:^(id x) {
        
    }];
}

- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status
{
    
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    
    [[ZZNotificationTransportService sendVideoStatusUpdateNotificationTo:friendModel
                                                             videoItemID:videoId
                                                                  status:status from:me] subscribeNext:^(id x) {
        
    }];
}

@end

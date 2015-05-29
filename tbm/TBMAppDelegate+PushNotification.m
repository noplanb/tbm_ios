//
//  TBMAppDelegate+PushNotification.m
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMHttpManager.h"
#import "TBMUser.h"
#import "TBMConfig.h"

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
//-----------------------
// Setup and registration
//-----------------------
- (void)registerForPushNotification {
    OB_INFO(@"registerForPushNotification");
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
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
    OB_INFO(@"didRegisterUserNotificationSettings: allowedTypes = %u", allowedTypes);
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
    if (self.notificationAllowedTypes != 0) {
        [self onGrantedPushAccess];
    } else {
        [self onFailPushAccess];
    };
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    OB_ERROR(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
    [self onFailPushAccess];
}

- (void)sendPushTokenToServer:(NSString *)token {
    OB_INFO(@"sendPushTokenToServer");
    NSDictionary *params = @{@"mkey" : [TBMUser getUser].mkey,
            @"device_build" : [TBMConfig deviceDebugModeString],
            @"push_token" : token,
            @"device_platform" : @"ios"};

    [[TBMHttpManager manager] POST:@"notification/set_push_token"
                        parameters:params
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               OB_INFO(@"notification/push_token: SUCCESS %@", responseObject);
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               OB_WARN(@"notification/push_token: %@", error);
                           }];
}

//------------------------------
// Handle Incoming Notifications
//------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Not used as all of our notification are of type content-available = 1.
    DebugLog(@"didReceiveRemoteNotification");
}

void (^_completionHandler)(UIBackgroundFetchResult);

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    OB_INFO(@"didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
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
    if ([nstatus isEqual:NOTIFICATION_STATUS_DOWNLOADED]) {
        outgoingStatus = OUTGOING_VIDEO_STATUS_DOWNLOADED;
    } else if ([nstatus isEqual:NOTIFICATION_STATUS_VIEWED]) {
        outgoingStatus = OUTGOING_VIDEO_STATUS_VIEWED;
    } else {
        OB_ERROR(@"unknown status received in notification");
        return;
    }

    [friend setAndNotifyOutgoingVideoStatus:outgoingStatus videoId:videoId];
}

//--------------------------------------
// Notification center and badge control
//--------------------------------------
#pragma mark Notification center and badge control

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


//----------------------------
// Send outgoing Notifications
//----------------------------
- (void)sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId {
    NSDictionary *params = @{
            NOTIFICATION_TARGET_MKEY_KEY : friend.mkey,
            NOTIFICATION_FROM_MKEY_KEY : [TBMUser getUser].mkey,
            NOTIFICATION_SENDER_NAME_KEY : [TBMUser getUser].firstName,
            NOTIFICATION_VIDEO_ID_KEY : videoId
    };
    [self sendNotification:@"notification/send_video_received" params:params];
}

- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status {
    NSDictionary *params = @{
            NOTIFICATION_TARGET_MKEY_KEY : friend.mkey,
            NOTIFICATION_TO_MKEY_KEY : [TBMUser getUser].mkey,
            NOTIFICATION_STATUS_KEY : status,
            NOTIFICATION_VIDEO_ID_KEY : videoId
    };
    [self sendNotification:@"notification/send_video_status_update" params:params];
}

- (void)sendNotification:(NSString *)path params:(NSDictionary *)params {
    [[TBMHttpManager manager] POST:path
                        parameters:params
                           success:nil
                           failure:nil];
}


@end

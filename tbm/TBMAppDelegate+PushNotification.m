//
//  TBMAppDelegate+PushNotification.m
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMHttpClient.h"
#import "TBMUser.h"
#import "OBLogger.h"

static NSString *NOTIFICATION_TARGET_MKEY_KEY = @"target_mkey";
static NSString *NOTIFICATION_FROM_MKEY_KEY = @"from_mkey";
static NSString *NOTIFICATION_SENDER_NAME_KEY = @"send_name";
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
- (void)setupPushNotificationCategory{
    [TBMFriend addVideoStatusNotificationDelegate:self];
}

- (void)registerForPushNotification{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeBadge)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * pushToken = [deviceToken description];
    pushToken = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    DebugLog(@"Push token: %@", pushToken);
    [self sendPushTokenToServer:pushToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DebugLog(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void) sendPushTokenToServer:(NSString *)token{
    NSDictionary *params = @{@"mkey": [TBMUser getUser].mkey,
                             @"push_token": token,
                             @"device_platform": @"ios"};
    
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
    POST:@"notification/set_push_token"
    parameters:params
    success:^(NSURLSessionDataTask *task, id responseObject) {
        OB_INFO(@"notification/push_token: SUCCESS %@", responseObject);
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        OB_ERROR(@"notification/push_token: %@", error);
    }];
    [task resume];

}

//------------------------------
// Handle Incoming Notifications
//------------------------------l
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // Not used as all of our notification are of type content-available = 1.
    DebugLog(@"didReceiveRemoteNotification");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    DebugLog(@"didReceiveRemoteNotification:fetchCompletionHandler");
    [self handleNotificationPayload:userInfo];
    // See doc/notification.txt for why we call the completion handler with sucess immediately here.
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)handleNotificationPayload:(NSDictionary *)userInfo{
    if ([self isVideoReceivedType:userInfo]){
        [self handleVideoReceivedNotification:userInfo];
    } else if ([self isVideoStatusUpdateType:userInfo]){
        [self handleVideoStatusUPdateNotification:userInfo];
    } else {
        OB_ERROR(@"handleNotificationPayload: ERROR unknown notification type received");
    }
}

- (NSString *)videoIdWithUserInfo:(NSDictionary *)userInfo{
    return [userInfo objectForKey:NOTIFICATION_VIDEO_ID_KEY];
}

- (BOOL)isVideoReceivedType:(NSDictionary *)userInfo{
    return [[userInfo objectForKey:NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_RECEIVED];
}

- (BOOL)isVideoStatusUpdateType:(NSDictionary *)userInfo{
    return [[userInfo objectForKey:NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE];
}

- (void)handleVideoReceivedNotification:(NSDictionary *)userInfo{
    NSString *videoId = [self videoIdWithUserInfo:userInfo];
    NSString *mkey = [userInfo objectForKey:NOTIFICATION_FROM_MKEY_KEY];
    TBMFriend *friend = [TBMFriend findWithMkey:mkey];
    [self queueDownloadWithFriend:friend videoId:videoId];
}

- (void)handleVideoStatusUPdateNotification:(NSDictionary *)userInfo{
    NSString *nstatus = [userInfo objectForKey:NOTIFICATION_STATUS_KEY];
    NSString *mkey = [userInfo objectForKey:NOTIFICATION_TO_MKEY_KEY];
    TBMFriend *friend = [TBMFriend findWithMkey:mkey];
    NSString *videoId = [userInfo objectForKey:NOTIFICATION_VIDEO_ID_KEY];
    
    TBMOutgoingVideoStatus outgoingStatus;
    if ([nstatus isEqual:NOTIFICATION_STATUS_DOWNLOADED])
        outgoingStatus = OUTGOING_VIDEO_STATUS_DOWNLOADED;
    else if ([nstatus isEqual:NOTIFICATION_STATUS_VIEWED])
        outgoingStatus = OUTGOING_VIDEO_STATUS_VIEWED;
    else
        OB_ERROR(@"unknown status received in notification");
    
    [friend setAndNotifyOutgoingVideoStatus:outgoingStatus videoId:videoId];
}

//--------------------------------------
// Notification center and badge control
//--------------------------------------
- (void)clearNotifcationCenter{
    DebugLog(@"clearNotifcationCenter:");
    // Cleanest way to clear them all is to transition badge number through 0.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self setBadgeNumber];
}

- (void)videoStatusDidChange:(id)object{
    [self setBadgeNumber];
}

- (void)setBadgeNumber{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[TBMVideo unviewedCount]];
}

//----------------------------
// Send outgoing Notifications
//----------------------------
- (void) sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId{
    NSDictionary *params = @{
        NOTIFICATION_TARGET_MKEY_KEY: friend.mkey,
        NOTIFICATION_FROM_MKEY_KEY: [TBMUser getUser].mkey,
        NOTIFICATION_SENDER_NAME_KEY: [TBMUser getUser].firstName,
        NOTIFICATION_VIDEO_ID_KEY: videoId
    };
    [self sendNotification:@"notification/send_video_received" params:params];
}

- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status{
    NSDictionary *params = @{
        NOTIFICATION_TARGET_MKEY_KEY: friend.mkey,
        NOTIFICATION_TO_MKEY_KEY: [TBMUser getUser].mkey,
        NOTIFICATION_STATUS_KEY: status,
        NOTIFICATION_VIDEO_ID_KEY: videoId
    };
    [self sendNotification:@"notification/send_video_status_update" params:params];
}

- (void) sendNotification:(NSString *)path params:(NSDictionary *)params{
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
        POST:path
        parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
          DebugLog(@"SUCCESS: POST: %@", path);
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
          DebugLog(@"ERROR: POST: %@: %@", path, [error localizedDescription]);
        }];
    [task resume];
}


@end

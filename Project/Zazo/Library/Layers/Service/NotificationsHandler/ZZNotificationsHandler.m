//
//  ZZNotificationsHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsHandler.h"
#import "ZZStoredSettingsManager.h"
#import "ZZNotificationTransportService.h"
#import "ZZNotificationDomainModel.h"
#import "FEMObjectDeserializer.h"

@interface ZZNotificationsHandler ()

@property (nonatomic, assign) BOOL isPushAlreadyFailed;
@property (nonatomic, assign) UIUserNotificationType notificationAllowedTypes; //TODO: ???

@end

@implementation ZZNotificationsHandler

- (void)registerForPushNotification
{
    OB_INFO(@"registerForPushNotification");
    if ([self _isIOS8OrHigher])
    {
        OB_INFO(@"registerForPushNotification: ios8+");
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        OB_INFO(@"registerForPushNotification: < ios8");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                               UIRemoteNotificationTypeSound |
                                                                               UIRemoteNotificationTypeBadge)];
    }
}

- (void)receivedPushNotificationsToken:(NSData*)deviceToken
{
    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];
    
    NSUInteger dataLength = [deviceToken length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
    }
    
    OB_INFO(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSString *pushToken = [deviceToken description];
    pushToken = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    DebugLog(@"Push token: %@", pushToken);
    
    if (![hexString isEqualToString:pushToken])
    {
        OB_ERROR(@"Token was wrong");
    }
    
    ANDispatchBlockToBackgroundQueue(^{
        [self _sendPushTokenToServer:hexString];
    });
    
    if ([self _userHasGrantedPushAccess])
    {
        OB_INFO(@"BOOT: Push access granted");
        // Note we do not call onResourcesAvailable here since it is called prior to ensuring push notification. This is because
        // on io7 we do not get a callback from the os if the user declines notifications.
    }
    else
    {
        [self _onFailPushAccess];
    }
}


#pragma mark - Private


- (void)_sendPushTokenToServer:(NSString *)token
{
    OB_INFO(@"sendPushTokenToServer");
    NSString *myMkey = [ZZStoredSettingsManager shared].userID;
    
    [[ZZNotificationTransportService uploadToken:token userMKey:myMkey] subscribeNext:^(id x) {
        OB_INFO(@"notification/push_token: SUCCESS %@", x);
    } error:^(NSError *error) {
        OB_WARN(@"notification/push_token: %@", error);
    }];
}


- (void)_onFailPushAccess
{
    OB_INFO(@"BOOT: Push access not granted");
    if (self.isPushAlreadyFailed)
    {
        return;
    }
    self.isPushAlreadyFailed = YES;
    OB_INFO(@"onFailPushAccess");
    
    //TODO: more to user interface delegate
    
//    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
//    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
//    NSString *msg = @"You must grant permission for NOTIFICATIONS."
//    " Go your device home screen. "
//    "Click Settings/Zazo and allow notifications for Zazo. "
//    "Zazo is a messaging app and requires notifications to operate.";
//    
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission" message:msg];
//    
//    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault
//                                             handler:^(SDCAlertAction *action) {
//                                                 exit(0);
//                                             }]];
//    
//    [alert presentWithCompletion:nil];
}

- (BOOL)_isIOS8OrHigher
{
    return [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
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
- (BOOL)_userHasGrantedPushAccess
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // ios8
        return self.notificationAllowedTypes != UIRemoteNotificationTypeNone;
    }
    else
    {
        // ios < 8
        // Note this never gets called in the case user has not granted access in io7 see above. So it is kind of useless.
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
    }
}



- (void)handleNotificationPayload:(NSDictionary *)userInfo
{
    ZZNotificationDomainModel* notification;
    notification = [FEMObjectDeserializer deserializeObjectExternalRepresentation:userInfo
                                                                     usingMapping:[ZZNotificationDomainModel mapping]];
    
    if ([self isVideoReceivedType:userInfo])
    {
        [self handleVideoReceivedNotification:userInfo];
    }
    else if ([self isVideoStatusUpdateType:userInfo])
    {
        [self handleVideoStatusUpdateNotification:userInfo];
    }
    else
    {
        OB_ERROR(@"handleNotificationPayload: ERROR unknown notification type received");
    }
}

- (NSString *)videoIdWithUserInfo:(NSDictionary *)userInfo
{
    return userInfo[NOTIFICATION_VIDEO_ID_KEY];
}

- (BOOL)isVideoReceivedType:(NSDictionary *)userInfo
{
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_RECEIVED];
}

- (BOOL)isVideoStatusUpdateType:(NSDictionary *)userInfo
{
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE];
}

- (void)handleVideoReceivedNotification:(NSDictionary *)userInfo {
    OB_INFO(@"handleVideoReceivedNotification:");
    NSString *videoId = [self videoIdWithUserInfo:userInfo];
    NSString *mkey = userInfo[NOTIFICATION_FROM_MKEY_KEY];
    TBMFriend *friend = [TBMFriend findWithMkey:mkey];
    
    if (friend == nil)
    {
        OB_INFO(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self getAndPollAllFriends];
        return;
    }
    [self queueDownloadWithFriendID:friend.idTbm videoId:videoId];
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

- (void)setBadgeCount:(NSInteger)count
{
    if (count == 0)
    {
        [self clearBadgeCount];
    }
    else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    }
}


#pragma mark -  Send outgoing Notifications
- (void)sendNotificationForVideoReceived:(TBMFriend*)friend videoId:(NSString *)videoId
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

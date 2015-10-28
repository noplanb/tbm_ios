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
#import "ZZUserDataProvider.h"
#import "TBMVideo.h"
#import "ZZFriendDataProvider.h"
#import "ZZApplicationPermissionsHandler.h"

@interface ZZNotificationsHandler ()

@property (nonatomic, assign) BOOL isPushAlreadyFailed;
@property (nonatomic, assign) UIUserNotificationType notificationAllowedTypes; //TODO: ???
@property (nonatomic, copy) NSString* pushVideoID;

@end

@implementation ZZNotificationsHandler

+ (void)registerToPushNotifications
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

+ (void)disablePushNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
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
    }
    else
    {
        [ZZApplicationPermissionsHandler showUserDeclinedPushAccessAlert];
    }
}

- (void)applicationRegisteredWithSettings:(UIUserNotificationSettings *)settings
{
    UIUserNotificationType allowedTypes = [settings types];
    OB_INFO(@"didRegisterUserNotificationSettings: allowedTypes = %lu", (unsigned long)allowedTypes);
    
    self.notificationAllowedTypes = allowedTypes;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)applicationDidFailToRegisterWithError:(NSError *)error
{
    OB_ERROR(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
    [ZZApplicationPermissionsHandler showUserDeclinedPushAccessAlert];
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

+ (BOOL)_isIOS8OrHigher
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

- (void)handlePushNotification:(NSDictionary*)userInfo
{
    OB_INFO(@"didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
    [self.delegate requestBackground];
    
    if ([ZZUserDataProvider authenticatedUser].isRegistered)
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

- (void)handleVideoReceivedNotification:(NSDictionary*)userInfo
{
    OB_INFO(@"handleVideoReceivedNotification:");
    
    ZZNotificationDomainModel* model = [self _modelFromNotificationData:userInfo];
    [self.delegate handleVideoReceivedNotification:model];
}

- (void)handleVideoStatusUpdateNotification:(NSDictionary*)userInfo
{
    OB_INFO(@"handleVideoStatusUPdateNotification:");
    ZZNotificationDomainModel* model = [self _modelFromNotificationData:userInfo];
    [self.delegate handleVideoStatusUpdateNotification:model];
}

- (ZZNotificationDomainModel*)_modelFromNotificationData:(NSDictionary*)data
{
    return [FEMObjectDeserializer deserializeObjectExternalRepresentation:data
                                                             usingMapping:[ZZNotificationDomainModel mapping]];
}

@end

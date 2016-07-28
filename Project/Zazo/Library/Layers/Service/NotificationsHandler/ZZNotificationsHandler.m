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
#import "ZZMessageNotificationDomainModel.h"
#import "FEMObjectDeserializer.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZApplicationPermissionsHandler.h"

@interface ZZNotificationsHandler ()

@property (nonatomic, assign) BOOL isPushAlreadyFailed;
@property (nonatomic, assign) UIUserNotificationType notificationAllowedTypes; //TODO: ???
@property (nonatomic, copy) NSString *pushVideoID;

@end

@implementation ZZNotificationsHandler

+ (void)registerToPushNotifications
{

    if ([ZZStoredSettingsManager shared].isPushNotificatonEnabled)
    {
        OB_INFO(@"registerForPushNotification");

        UIUserNotificationType types = UIUserNotificationTypeBadge |
                UIUserNotificationTypeSound |
                UIUserNotificationTypeAlert;

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

+ (void)disablePushNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)receivedPushNotificationsToken:(NSData *)deviceToken
{
    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];

    NSUInteger dataLength = [deviceToken length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
    }

    ZZLogInfo(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSString *pushToken = [deviceToken description];
    pushToken = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    ZZLogInfo(@"Push token: %@", pushToken);

    if (![hexString isEqualToString:pushToken])
    {
        ZZLogError(@"Token was wrong");
    }

    ANDispatchBlockToBackgroundQueue(^{
        [self _sendPushTokenToServer:hexString];
    });

    if ([self _userHasGrantedPushAccess])
    {
        ZZLogInfo(@"BOOT: Push access granted");
    }
    else
    {
        ZZLogInfo(@"BOOT: Push access declined");
    }
}

- (void)applicationRegisteredWithSettings:(UIUserNotificationSettings *)settings
{
    UIUserNotificationType allowedTypes = [settings types];
    ZZLogInfo(@"didRegisterUserNotificationSettings: allowedTypes = %lu", (unsigned long)allowedTypes);

    self.notificationAllowedTypes = allowedTypes;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)applicationDidFailToRegisterWithError:(NSError *)error
{
    ZZLogError(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

#pragma mark - Private


- (void)_sendPushTokenToServer:(NSString *)token
{
    ZZLogInfo(@"sendPushTokenToServer");
    NSString *myMkey = [ZZStoredSettingsManager shared].userID;

    [[ZZNotificationTransportService uploadToken:token userMKey:myMkey] subscribeNext:^(id x) {
        ZZLogInfo(@"notification/push_token: SUCCESS %@", x);
    }                                                                           error:^(NSError *error) {
        ZZLogWarning(@"notification/push_token: %@", error);
    }];
}

- (BOOL)_userHasGrantedPushAccess
{
    return self.notificationAllowedTypes != UIUserNotificationTypeNone;
}

- (void)handlePushNotification:(NSDictionary *)userInfo
{
    ZZLogInfo(@"didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
    [self.delegate requestBackground];

    if ([ZZUserDataProvider authenticatedUser].isRegistered)
    {
        if ([self isVideoReceivedType:userInfo])
        {
            [self handleVideoReceivedNotification:userInfo];
        }
        if ([self isMessageReceivedType:userInfo])
        {
            [self handleMessageReceivedNotification:userInfo];
        }
        else if ([self isVideoStatusUpdateType:userInfo])
        {
            [self handleVideoStatusUpdateNotification:userInfo];
        }
        else
        {
            ZZLogError(@"handleNotificationPayload: ERROR unknown notification type received");
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

- (BOOL)isMessageReceivedType:(NSDictionary *)userInfo
{
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_MESSAGE_RECEIVED];
}

- (BOOL)isVideoStatusUpdateType:(NSDictionary *)userInfo
{
    return [userInfo[NOTIFICATION_TYPE_KEY] isEqualToString:NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE];
}

- (void)handleMessageReceivedNotification:(NSDictionary *)userInfo
{
    FEMObjectMapping *mapping = ZZMessageNotificationDomainModel.mapping;
    
    ZZMessageNotificationDomainModel *messageModel =
    [FEMObjectDeserializer deserializeObjectExternalRepresentation:userInfo usingMapping:mapping];
    
    [self.delegate handleMessageReceivedNotification:messageModel];
}

- (void)handleVideoReceivedNotification:(NSDictionary *)userInfo
{
    ZZLogInfo(@"handleVideoReceivedNotification:");

    ZZNotificationDomainModel *model = [self _modelFromNotificationData:userInfo];
    [self.delegate handleVideoReceivedNotification:model];
}

- (void)handleVideoStatusUpdateNotification:(NSDictionary *)userInfo
{
    ZZLogInfo(@"handleVideoStatusUPdateNotification:");
    ZZNotificationDomainModel *model = [self _modelFromNotificationData:userInfo];
    [self.delegate handleVideoStatusUpdateNotification:model];
}

- (ZZNotificationDomainModel *)_modelFromNotificationData:(NSDictionary *)data
{
    return [FEMObjectDeserializer deserializeObjectExternalRepresentation:data
                                                             usingMapping:[ZZNotificationDomainModel mapping]];
}

@end

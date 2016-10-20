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
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZApplicationPermissionsHandler.h"
#import "ZZNotificationsConstants.h"

#import "FEMObjectDeserializer.h"

NSString * const ZZMessageCategoryIdentifier = @"MESSAGE_CATEGORY";
NSString * const ZZMessageTextActionIdentifier = @"TEXT_ACTION";
NSString * const ZZMessageVideoActionIdentifier = @"VIDEO_ACTION";

typedef void(^ZZNotificationsHandlerBlock)(NSDictionary *userData);

@interface ZZNotificationsHandler ()

@property (nonatomic, assign) BOOL isPushAlreadyFailed;
@property (nonatomic, assign) UIUserNotificationType notificationAllowedTypes; //TODO: ???
@property (nonatomic, copy) NSString *pushVideoID;
@property (nonatomic, strong) NSMutableDictionary <NSString *, ZZNotificationsHandlerBlock> *handlers;

@end

@implementation ZZNotificationsHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _handlers = [NSMutableDictionary new];
    }
    return self;
}

+ (void)registerToPushNotifications
{
    if ([PermissionScope new].statusNotifications != PermissionStatusAuthorized)
    {
        return;
    }
    
    if ([ZZStoredSettingsManager shared].isPushNotificatonEnabled)
    {
        OB_INFO(@"registerForPushNotification");

        UIUserNotificationType types = UIUserNotificationTypeBadge |
                UIUserNotificationTypeSound |
                UIUserNotificationTypeAlert;

        NSSet *categories = [NSSet setWithObject:[self messageCategory]];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

+ (void)disablePushNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

+ (UIUserNotificationCategory *)messageCategory
{
    UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
    
    messageCategory.identifier = ZZMessageCategoryIdentifier;
    
    UIMutableUserNotificationAction *textAction = [UIMutableUserNotificationAction new];
    textAction.identifier = ZZMessageTextActionIdentifier;
    textAction.title = @"Text";
    textAction.activationMode = UIUserNotificationActivationModeForeground;
    
    UIMutableUserNotificationAction *videoAction = [UIMutableUserNotificationAction new];
    videoAction.identifier = ZZMessageVideoActionIdentifier;
    videoAction.title = @"Zazo";
    videoAction.activationMode = UIUserNotificationActivationModeForeground;
    
    [messageCategory setActions:@[textAction, videoAction]
                     forContext:UIUserNotificationActionContextDefault];
    
    return [messageCategory copy];
}

- (void)registerHandlerForActionIdentifier:(NSString *)identifier
                                   handler:(ZZNotificationsHandlerBlock)handler {
    
    if (ANIsEmpty(identifier)) {
        ZZLogError(@"identifier is empty");
        return;
    }
    
    self.handlers[identifier] = handler;
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

- (NSString *)handlePushNotification:(NSDictionary *)userInfo
{
    ZZLogInfo(@"didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
    [self.delegate requestBackground];

    if ([ZZUserDataProvider authenticatedUser].isRegistered)
    {
        NSString *typeString = userInfo[NOTIFICATION_TYPE_KEY];
        ZZNotificationType type = ZZNotificationTypeEnumValueFromString(typeString);
        
        switch (type) {
                
            case ZZNotificationTypeVideoReceived:
                return [self handleVideoReceivedNotification:userInfo];
                break;
                
            case ZZNotificationTypeVideoStatusUpdate:
                [self handleVideoStatusUpdateNotification:userInfo];
                break;
                
            case ZZNotificationTypeMessageReceived:
                [self handleMessageReceivedNotification:userInfo];
                break;
                
            default:
                ZZLogError(@"handleNotificationPayload: ERROR unknown notification type received");
                break;
        }
    }
    
    return nil;
}

- (NSString *)videoIdWithUserInfo:(NSDictionary *)userInfo
{
    return userInfo[NOTIFICATION_VIDEO_ID_KEY];
}

- (void)handleMessageReceivedNotification:(NSDictionary *)userInfo
{
    FEMObjectMapping *mapping = ZZMessageNotificationDomainModel.mapping;
    
    ZZMessageNotificationDomainModel *messageModel =
    [FEMObjectDeserializer deserializeObjectExternalRepresentation:userInfo usingMapping:mapping];
    
    [self.delegate handleMessageReceivedNotification:messageModel];
}

- (NSString *)handleVideoReceivedNotification:(NSDictionary *)userInfo
{
    ZZLogInfo(@"handleVideoReceivedNotification:");

    ZZNotificationDomainModel *model = [self _modelFromNotificationData:userInfo];
    [self.delegate handleVideoReceivedNotification:model];
    
    return model.fromUserMKey;
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

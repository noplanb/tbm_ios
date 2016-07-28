//
//  ZZNotificationsHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZNotificationDomainModel, ZZMessageNotificationDomainModel;

@protocol ZZNotificationsHandlerDelegate <NSObject>

- (void)requestBackground;

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel *)model;
- (void)handleMessageReceivedNotification:(ZZMessageNotificationDomainModel *)notificationModel;
- (void)handleVideoReceivedNotification:(ZZNotificationDomainModel *)model;

@end

@interface ZZNotificationsHandler : NSObject

@property (nonatomic, weak) id <ZZNotificationsHandlerDelegate> delegate;

+ (void)registerToPushNotifications;

- (void)receivedPushNotificationsToken:(NSData *)token;

+ (void)disablePushNotifications;

- (void)handlePushNotification:(NSDictionary *)notification;

- (void)applicationRegisteredWithSettings:(UIUserNotificationSettings *)settings;

- (void)applicationDidFailToRegisterWithError:(NSError *)error;

@end

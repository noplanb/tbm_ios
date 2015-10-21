//
//  ZZNotificationsHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZNotificationDomainModel;

@protocol ZZNotificationsHandlerDelegate <NSObject>

- (void)requestBackground;

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel*)model;
- (void)handleVideoReceivedNotification:(ZZNotificationDomainModel*)model;

@end

@protocol ZZNotificationsHandlerUserInterfaceDelegate <NSObject>

- (void)userDeclinedAccessToNotifications;

@end

@interface ZZNotificationsHandler : NSObject

@property (nonatomic, weak) id<ZZNotificationsHandlerDelegate> delegate;
@property (nonatomic, weak) id<ZZNotificationsHandlerUserInterfaceDelegate> userInterface;

- (void)registerForPushNotification;
- (void)receivedPushNotificationsToken:(NSData*)token;

- (void)handlePushNotification:(NSDictionary*)notification;
- (void)applicationRegisteredWithSettings:(UIUserNotificationSettings*)settings;
- (void)applicationDidFailToRegisterWithError:(NSError*)error;

@end

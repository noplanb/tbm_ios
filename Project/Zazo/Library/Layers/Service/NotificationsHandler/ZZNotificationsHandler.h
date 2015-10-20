//
//  ZZNotificationsHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@protocol ZZNotificationsHandlerUserInterfaceDelegate <NSObject>

- (void)showNotificationsPermissionDeclinedAlert;
- (void)requestBackground;

@end

@interface ZZNotificationsHandler : NSObject

@property (nonatomic, weak) id<ZZNotificationsHandlerUserInterfaceDelegate> delegate;

- (void)registerForPushNotification;
- (void)receivedPushNotificationsToken:(NSData*)token;

- (void)handlePushNotification:(NSDictionary*)notification;
- (void)applicationRegisteredWithSettings:(UIUserNotificationSettings*)settings;
- (void)applicationDidFailToRegisterWithError:(NSError*)error;

@end

//
//  ZZNotificationsHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@protocol ZZNotificationsHandlerUserInterfaceDelegate <NSObject>

- (void)showNotificationsPermissionDeclinedAlert;

@end

@interface ZZNotificationsHandler : NSObject

@property (nonatomic, weak) id<ZZNotificationsHandlerUserInterfaceDelegate> delegate;


- (BOOL)usesIos8PushRegistration;
- (void)registerForPushNotification;
- (void)receivedPushNotificationsToken:(NSData*)token;



@end

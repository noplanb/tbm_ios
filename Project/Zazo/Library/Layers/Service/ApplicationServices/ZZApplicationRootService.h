//
//  ZZApplicationRootService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsHandler.h"

@protocol ZZApplicationRootServiceNotificationDelegate <NSObject>

- (void)registerToPushNotifications;

@end

@interface ZZApplicationRootService : NSObject <ZZNotificationsHandlerDelegate>

@property (nonatomic, weak) id<ZZApplicationRootServiceNotificationDelegate> notificationDelegate;

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)updateBadgeCounter;
- (void)checkApplicationPermissionsAndResources;

@end

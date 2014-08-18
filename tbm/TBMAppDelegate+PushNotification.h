//
//  TBMAppDelegate+PushNotification.h
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"
#import "TBMFriend.h"

static NSString *NOTIFICATION_STATUS_DOWNLOADED = @"downloaded";
static NSString *NOTIFICATION_STATUS_VIEWED = @"viewed";

@interface TBMAppDelegate (PushNotification)
- (void)setupPushNotificationCategory;
- (void)registerForPushNotification;
- (void)clearNotifcationCenter;
- (void)videoStatusDidChange:(id)object;

- (void)handleNotificationPayload:(NSDictionary *)userInfo;


// Send outgoing Notifications
- (void)sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId;
- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status;
@end
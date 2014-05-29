//
//  TBMAppDelegate+PushNotification.h
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"

@interface TBMAppDelegate (PushNotification)
- (void)setupPushNotificationCategory;
- (void)registerForPushNotification;
- (void)handleSyncPayload:(NSDictionary *)userInfo;
- (void)clearNotifcationCenter;
- (void)videoStatusDidChange:(id)object;
@end
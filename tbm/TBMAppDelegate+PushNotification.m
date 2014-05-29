//
//  TBMAppDelegate+PushNotification.m
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+PushNotification.h"
#import "TBMHttpClient.h"
#import "TBMUser.h"
#import "TBMAppSyncManager.h"

@implementation TBMAppDelegate (PushNotification)

- (void)registerForPushNotification{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeBadge)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * pushToken = [deviceToken description];
    pushToken = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    DebugLog(@"Push token: %@", pushToken);
    [self sendPushTokenToServer:pushToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DebugLog(@"ERROR: didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void) sendPushTokenToServer:(NSString *)token{
    NSDictionary *params = @{@"user_id": [TBMUser getUser].idTbm,
                             @"push_token": token,
                             @"device_platform": @"ios"};
    
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient] POST:@"reg/push_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DebugLog(@"reg/push_token: %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DebugLog(@"reg/push_token: ERROR: %@", error);
    }];
    [task resume];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // Not used as all of our notification are of type content-available = 1.
    DebugLog(@"didReceiveRemoteNotification");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    DebugLog(@"didReceiveRemoteNotification:fetchCompletionHandler");
    [TBMAppSyncManager handleSyncPayload:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end

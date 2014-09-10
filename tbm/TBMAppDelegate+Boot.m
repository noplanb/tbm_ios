//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "OBLogger.h"

@implementation TBMAppDelegate (Boot)


- (void) boot{
    OB_INFO(@"Boot");
    
    [OBLogger instance].writeToConsole = YES;
    // [[OBLogger instance] reset];

    
    TBMUser *user = [TBMUser getUser];
    NSArray *friends = [TBMFriend all];
    if (!user || [friends count] == 0){
        self.window.rootViewController = [self registerViewController];
    } else {
        self.window.rootViewController = [self homeViewController];
        [self setupPushNotificationCategory];
        [self registerForPushNotification];
    }
}


@end

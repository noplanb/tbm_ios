//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMS3CredentialsManager.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "OBLogger.h"
#import "TBMDispatch.h"

@implementation TBMAppDelegate (Boot)

- (void) boot{
    OB_INFO(@"Boot");

    [TBMDispatch enable];
    
    if (![TBMUser getUser].isRegistered){
        self.window.rootViewController = [self registerViewController];
    } else {
        self.window.rootViewController = [self homeViewController];
        [self postRegistrationBoot];
    }
}

- (void)didCompleteRegistration{
    OB_INFO(@"didCompleteRegistration");
    [[self registerViewController] presentViewController:[self homeViewController] animated:YES completion:nil];
    [self postRegistrationBoot];
    [self performDidBecomeActiveActions];
}

- (void)postRegistrationBoot{
    [self setupPushNotificationCategory];
    [self registerForPushNotification];
    [TBMS3CredentialsManager refreshFromServer:nil];
}

- (void)performDidBecomeActiveActions{
    OB_INFO(@"performDidBecomeActiveActions: registered: %d", [TBMUser getUser].isRegistered);

    if (![TBMUser getUser].isRegistered)
        return;
    
    [TBMVideo printAll];
    [self handleStuckDownloadsWithCompletionHandler:^{
        [self retryPendingFileTransfers];
        [self getAndPollAllFriends];
    }];
}


@end

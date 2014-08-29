//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Boot.h"
#import "TBMFriend.h"
#import "TBMUser.h"
#import "TBMRegisterViewController.h"
#import "TBMHttpClient.h"
#import "UIAlertView+AFNetworking.h"
#import "NSArray+NSArrayExtensions.h"
#import "TBMAppDelegate+PushNotification.h"
#import "OBLogger.h"

@implementation TBMHomeViewController (Boot)

static UIAlertView *getFriendsErrorAlert = nil;

- (void) boot{
    DebugLog(@"Boot");
    TBMUser *user = [TBMUser getUser];
    NSArray *friends = [TBMFriend all];
    if (!user || [friends count] == 0){
        [self showRegister];
    } else {
        [self userAndFriendModelsAreSetup];
    }
}

- (void) userAndFriendModelsAreSetup{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self registerForPushNotification];
}

- (void) registerForPushNotification{
    TBMAppDelegate *tbmAppDelegate = [[UIApplication sharedApplication] delegate];
    [tbmAppDelegate registerForPushNotification];
}

- (void) showRegister{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TBM" bundle:nil];
    TBMRegisterViewController *registerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TBMRegisterViewController2"];
    registerViewController.delegate = self;
    [self presentViewController:registerViewController animated:YES completion:nil];
}

- (void) didSelectUser:(NSDictionary *)user{
    DebugLog(@"didSelectUser: %@", user);
    TBMUser *u = [TBMUser createWithIdTbm:[user objectForKey:@"id"]];
    u.firstName = [user objectForKey:@"first_name"];
    u.lastName = [user objectForKey:@"last_name"];
    u.auth = [user objectForKey:@"auth"];
    u.mkey = [user objectForKey:@"mkey"];
    [self getFriends];
}

- (void) getFriends{
    NSString *path = @"reg/get_friends";
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient] GET:path parameters:@{@"mkey": [TBMUser getUser].mkey}
    success:^(NSURLSessionDataTask *task, id responseObject) {
        DebugLog(@"getFriends: %@", responseObject);
        [self addFriends:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DebugLog(@"getFriends: ERROR: %@", error);
        [self showGetFriendsErrorAlertWithError:error];
    }];
    [task resume];
}

- (void) showGetFriendsErrorAlertWithError:(NSError *)error{
    NSString *errorMsg = [NSString stringWithFormat:@"%@ Check your internet connection and try again.", [error localizedDescription]];
    getFriendsErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [getFriendsErrorAlert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView == getFriendsErrorAlert){
        [self getFriends];
    }
}

- (void) addFriends:(NSMutableArray *)friends{
    [TBMFriend destroyAll];
    int i  = 0;
    for (NSDictionary *f in friends){
        TBMFriend *friend = [TBMFriend newWithId:[f objectForKey:@"id"]];
        friend.viewIndex = [NSNumber numberWithInt:i];
        friend.firstName = [f objectForKey:@"first_name"];
        friend.lastName = [f objectForKey:@"last_name"];
        friend.mkey = [f objectForKey:@"mkey"];
        i++;
    }
    [TBMFriend saveAll];
    [self userAndFriendModelsAreSetup];
}

@end

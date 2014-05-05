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
#import "TBMRegisterTableViewController.h"
#import "TBMHttpClient.h"
#import "UIAlertView+AFNetworking.h"
#import "NSArray+NSArrayExtensions.h"

@implementation TBMHomeViewController (Boot)

- (void)boot{
    TBMUser *user = [TBMUser getUser];
    NSArray *friends = [TBMFriend all];
    DebugLog(@"User = %@", user.firstName);
    DebugLog(@"Friends:");
    for (TBMFriend *f in friends){
        DebugLog(@"%@: %@", f.firstName, f);
    }

    if (!user || [friends count] == 0)
        [self showRegister];
}

- (void) showRegister{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TBM" bundle:nil];
    TBMRegisterTableViewController *registerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TBMRegisterViewController"];
    registerViewController.delegate = self;
    [self presentViewController:registerViewController animated:YES completion:nil];
}

- (void) didSelectUser:(NSDictionary *)user{
    DebugLog(@"didSelectUser: %@", user);
    [self dismissViewControllerAnimated:YES completion:nil];
    TBMUser *u = [TBMUser createWithIdTbm:[user objectForKey:@"id"]];
    u.firstName = [user objectForKey:@"first_name"];
    u.lastName = [user objectForKey:@"last_name"];
    [self getFriends];
}

- (void) getFriends{
    NSString *path = [NSString stringWithFormat:@"reg/register/%@", [TBMUser getUser].idTbm];
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DebugLog(@"getFriends: %@", responseObject);
        [self addFriends:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DebugLog(@"getFriends: ERROR: %@", error);
    }];
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [task resume];
}

- (void) addFriends:(NSMutableArray *)friends{
    [TBMFriend destroyAll];
    int i  = 0;
    for (NSDictionary *f in friends){
        TBMFriend *friend = [TBMFriend newWithId:[f objectForKey:@"id"]];
        friend.viewIndex = [NSNumber numberWithInt:i];
        friend.firstName = [f objectForKey:@"first_name"];
        friend.lastName = [f objectForKey:@"last_name"];
        i++;
    }
    [TBMFriend saveAll];
}

@end

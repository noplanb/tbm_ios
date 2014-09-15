//
//  TBMRegisterViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMHttpClient.h"
#import "TBMRegisterViewController.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMFriend.h"

static UIAlertView *getFriendsErrorAlert = nil;

@interface TBMRegisterViewController ()
- (void) sendMobileNumber:(NSString *)mobileNumber;
- (void) gotUser:(NSDictionary *)userDict;
- (void) userNotFound;
- (void) connectionError;
- (void) startWaitingForServer;
- (void) stopWaitingForServer;
@end

@implementation TBMRegisterViewController

//--------------------
// ViewControllerState
//--------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [_spinner stopAnimating];
    _mobileNumber.delegate = self;
    _isWaiting = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


//---------------------
// Registration actions
//---------------------
- (IBAction)didEnterMobileNumber:(id)sender {
    DebugLog(@"didEnterMobileNumber: %@", self.mobileNumber.text);
    NSString *mobileNumber = [self.mobileNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([mobileNumber isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Enter your phone number with area code." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self sendMobileNumber: mobileNumber];
}

- (void)sendMobileNumber:(NSString *)mobileNumber{
    DebugLog(@"sendMobileNumber: %@", mobileNumber);
    [self startWaitingForServer];
    TBMHttpClient *httpClient = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [httpClient
      GET:@"reg/get_user"
      parameters:@{@"mobile_number": mobileNumber}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          DebugLog(@"get_user success: %@", responseObject);
          [self stopWaitingForServer];
          [self gotUser:responseObject];
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          DebugLog(@"get_user fail: %@", error);
          [self stopWaitingForServer];
          [self connectionError];
      }];
    [task resume];
}

- (void)gotUser:(NSDictionary *)userDict{
    if ([userDict objectForKey:@"auth"] == NULL){
        [self userNotFound];
        return;
    }
    [self didSelectUser:userDict];
}

- (void) connectionError{
    DebugLog(@"connectionError:");
    NSString *message = [NSString stringWithFormat:@"Unable to reach the %@ please check your Internet connection and try again.", TBMConfig.appName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void) userNotFound{
    DebugLog(@"userNotFound:");
    NSString *message = [NSString stringWithFormat:@"User not found with mobile number %@. \n\n Check the number or contact Sani Elfishawy for help. \n\n Sani Elfishawy \n650-245-3537 \n sani@sbcglobal.net", [_mobileNumber text]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
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
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
        GET:path
        parameters:@{@"mkey": [TBMUser getUser].mkey}
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

- (void) userAndFriendModelsAreSetup{
    [(TBMAppDelegate *)[[UIApplication sharedApplication] delegate] didCompleteRegistration];
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    DebugLog(@"textFieldShouldBeginEditing");
    return !_isWaiting;
}

- (void) startWaitingForServer{
    _isWaiting = YES;
    [_spinner startAnimating];
}

- (void) stopWaitingForServer{
    _isWaiting = NO;
    [_spinner stopAnimating];
}

@end

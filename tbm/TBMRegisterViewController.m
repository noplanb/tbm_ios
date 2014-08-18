//
//  TBMRegisterViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHttpClient.h"
#import "TBMRegisterViewController.h"
#import "TBMConfig.h"

@interface TBMRegisterViewController ()
- (void) sendMobileNumber:(NSString *)mobileNumber;
- (void) gotUser:(NSDictionary *)userDict;
- (void) userNotFound;
- (void) connectionError;
- (void) startWaitingForServer;
- (void) stopWaitingForServer;
@end

@implementation TBMRegisterViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didEnterMobileNumber:(UITextField *)sender {
    DebugLog(@"didEnterMobileNumber: %@", [sender text]);
    NSString *mobileNumber = [[sender text] stringByReplacingOccurrencesOfString:@" " withString:@""];
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
    [_delegate didSelectUser:userDict];
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

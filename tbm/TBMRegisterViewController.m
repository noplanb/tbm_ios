//
//  TBMRegisterViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMRegisterViewController.h"
#import "TBMHttpClient.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "NBPhoneNumberUtil.h"
#import "OBLogger.h"
#import "TBMTextField.h"
#import "TBMPhoneUtils.h"
#import "UIAlertView+Blocks.h"
#import "TBMAlertController.h"


@interface TBMRegisterViewController ()

@property (nonatomic) TBMRegisterForm *registerForm;

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *mobileNumber;
@property (nonatomic) NSString *combinedNumber;
@property (nonatomic) NSString *verificationCode;
@property (nonatomic) NSString *auth;
@property (nonatomic) NSString *mkey;

@end

@implementation TBMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_registerForm stopWaitingForServer];
    self.registerForm = [[TBMRegisterForm alloc] initWithView:self.view delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//----------------
// Submit reg form
//----------------
- (void) didClickSubmit{
    [self getInput];
    [self putInput];
    if (![self isValidInput])
        return;
    [self register];
}

- (void) didClickDebug{
    [self debugGetUser];
    return;
}


//-----------------------
// Get and Validate Input
//-----------------------
- (void)getInput{
    _firstName = [self cleanName:_registerForm.firstName.text];
    _lastName  = [self cleanName:_registerForm.lastName.text];
    _countryCode  = [self cleanNumber:_registerForm.countryCode.text];
    _mobileNumber = [self cleanNumber:_registerForm.mobileNumber.text ];
    _combinedNumber = [NSString stringWithFormat:@"+%@%@", _countryCode, _mobileNumber];
}

- (void) putInput{
    _registerForm.firstName.text = _firstName;
    _registerForm.lastName.text = _lastName;
    _registerForm.countryCode.text = _countryCode;
    _registerForm.mobileNumber.text = _mobileNumber;
}

- (BOOL)isValidInput{
    if ([_firstName isEqualToString:@""]){
        [self showErrorDialogWithTitle:@"First Name" msg:@"Enter your first name."];
        return NO;
    }
    if ([_lastName isEqualToString:@""]){
        [self showErrorDialogWithTitle:@"Last Name" msg:@"Enter your last name."];
        return NO;
    }
    if ([_countryCode isEqualToString:@""]){
        [self showErrorDialogWithTitle:@"Country Code" msg:@"Enter your country code. It is 1 for USA"];
        return NO;
    }
    if ([_mobileNumber isEqualToString:@""]){
        [self showErrorDialogWithTitle:@"Mobile Number" msg:@"Enter your mobile number."];
        return NO;
    }
    if (![TBMPhoneUtils isValidPhone: _combinedNumber]){
        [self showErrorDialogWithTitle:@"Bad Number" msg:@"Enter a valid country code and mobile number."];
        return NO;
    }
    return YES;
}

- (NSString *)cleanName:(NSString *)name{
    NSError *error = nil;
    NSArray *rxs = @[@"\\s+", @"\\W+", @"\\d+"];
    for (NSString *rx in rxs){
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:rx options:NSRegularExpressionCaseInsensitive error:&error];
        name = [regex stringByReplacingMatchesInString:name options:0 range:NSMakeRange(0, [name length]) withTemplate:@""];
    }
    return name;
}

- (NSString *)cleanNumber:(NSString *)phone{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D+" options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
}


//---------
// Register
//---------

- (void)register{
    [_registerForm startWaitingForServer];
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [hc
                                  GET:@"reg/reg"
                                  parameters:[self userParams]
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      DebugLog(@"register success: %@", responseObject);
                                      [_registerForm stopWaitingForServer];
                                      [self didRegister:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DebugLog(@"register fail: %@", error);
                                      [_registerForm stopWaitingForServer];
                                      [self connectionError];
                                  }];
    [task resume];
}

- (NSDictionary *)userParams{
    NSMutableDictionary *r = [[NSMutableDictionary alloc] init];
    [r setObject:@"ios" forKey:SERVER_PARAMS_USER_DEVICE_PLATFORM_KEY];
    [r setObject:_firstName forKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    [r setObject:_lastName forKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    
    NSString *pn = [TBMPhoneUtils phone:_combinedNumber withFormat:NBEPhoneNumberFormatE164];
    if (pn != nil)
        [r setObject:pn forKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    
    if (_auth != nil)
        [r setObject:_auth forKey:SERVER_PARAMS_USER_AUTH_KEY];
    
    if (_mkey != nil)
        [r setObject:_mkey forKey:SERVER_PARAMS_USER_MKEY_KEY];
    
    if (_verificationCode != nil)
        [r setObject:_verificationCode forKey:SERVER_PARAMS_USER_VERIFICATION_CODE_KEY];
    
    return r;
}

- (void)didRegister:(NSDictionary *)params{
    if ([TBMHttpClient isSuccess:params]){
        _auth = [params objectForKey:SERVER_PARAMS_USER_AUTH_KEY];
        _mkey = [params objectForKey:SERVER_PARAMS_USER_MKEY_KEY];
        [self showVerificationDialog];
    } else {
        NSString *title = [params objectForKey:SERVER_PARAMS_ERROR_TITLE_KEY];
        NSString *msg = [params objectForKey:SERVER_PARAMS_ERROR_MSG_KEY];
        [self showErrorDialogWithTitle:title msg:msg];
    }
}


//------------------
// Verification code
//------------------
- (void)didEnterCode{
    [_registerForm startWaitingForServer];
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [hc
                                  GET:@"reg/verify_code"
                                  parameters:[self userParams]
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      DebugLog(@"register success: %@", responseObject);
                                      [_registerForm stopWaitingForServer];
                                      [self didReceiveCodeResponse:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DebugLog(@"register fail: %@", error);
                                      [_registerForm stopWaitingForServer];
                                      [self connectionError];
                                  }];
    [task resume];
}

- (void)didReceiveCodeResponse:(NSDictionary *)params{
    if ([TBMHttpClient isSuccess:params]){
        [self gotUser:params];
    } else {
        [self showErrorDialogWithTitle:@"Bad Code" msg:@"The code you enterred is wrong. Please try again"];
    }
}

//---------------
// Debug_get_user
//---------------
- (void)debugGetUser{
[_registerForm startWaitingForServer];
TBMHttpClient *hc = [TBMHttpClient sharedClient];
NSURLSessionDataTask *task = [hc
                              GET:@"reg/debug_get_user"
                              parameters:@{@"mobile_number": self.registerForm.mobileNumber.text}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  DebugLog(@"register success: %@", responseObject);
                                  [_registerForm stopWaitingForServer];
                                  [self didReceiveCodeResponse:responseObject];
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  DebugLog(@"register fail: %@", error);
                                  [_registerForm stopWaitingForServer];
                                  [self connectionError];
                              }];
[task resume];
}

//---------
// Got user
//---------
- (void)gotUser:(NSDictionary *)params{
    [TBMUser createWithServerParams:params];
    [self getFriends];
}

//------------
// Got friends
//------------
- (void) getFriends{
    [_registerForm startWaitingForServer];
    [[[TBMFriendGetter alloc] initWithDelegate:self destroyAll:YES] getFriends];
}

- (void) gotFriends{
    [_registerForm stopWaitingForServer];
    [self userAndFriendModelsAreSetup];
}

- (void) friendGetterServerError{
    [_registerForm stopWaitingForServer];
    [self showGetFriendsServerErrorDialog];
}

//--------
// Dialogs
//--------
- (void) connectionError{
    DebugLog(@"connectionError:");
    NSString *msg = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", TBMConfig.appName];
    [self showErrorDialogWithTitle:@"Try Again" msg:msg];
}

- (void) showErrorDialogWithTitle:(NSString *)title msg:(NSString *)msg {
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Okay" style:SDCAlertActionStyleCancel handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void) showVerificationDialog{
    NSString *msg = [NSString stringWithFormat:@"We sent a code via text message to\n\n%@", [TBMPhoneUtils phone:_combinedNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL]];
    UIAlertView *av = [[UIAlertView alloc]
                          initWithTitle:@"Enter Code"
                                message:msg
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Enter", nil];
    

    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tf = [av textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.placeholder = @"Enter code";
    NSString *fname = tf.font.fontName;
    tf.font = [UIFont fontWithName:fname size:20.0f];
    
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            _verificationCode = [self cleanNumber:[tf text]];
            [self didEnterCode];
        } else if (buttonIndex == alertView.cancelButtonIndex) {
        }
    };
    
    av.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView) {
        return ([[tf text] length] > 0);
    };
    
    [av show];
}

- (void) showGetFriendsServerErrorDialog{
    NSString *msg = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", CONFIG_APP_NAME];

    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Bad Connection"
                       message:msg
                       delegate:self
                       cancelButtonTitle:@"Try Again"
                       otherButtonTitles:nil];

    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self getFriends];
    };
    [av show];
}


//--------------
// Done with reg
//--------------


- (void) userAndFriendModelsAreSetup{
    [(TBMAppDelegate *)[[UIApplication sharedApplication] delegate] didCompleteRegistration];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end

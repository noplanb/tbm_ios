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


@interface TBMRegisterViewController ()

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
    [self fixTextFields];
    [self stopWaitingForServer];
}

- (void) fixTextFields{
    NSArray *fields = @[_firstNameTxt, _lastNameTxt, _mobileNumberTxt, _countryCodeTxt];
    for (UITextField *f in fields){
        f.layer.borderWidth = 1.0;
        f.layer.borderColor = [[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1.0f] CGColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//------------------
// Textfield Control
//------------------
- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    UITextField *nextField = [(TBMTextField *)textField nextField];
    if ([textField isKindOfClass:[TBMTextField class]] && nextField != nil){
        [nextField becomeFirstResponder];
    }
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    DebugLog(@"textFieldShouldBeginEditing");
    return !_isWaiting;
}

- (void) hideKeyboard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

//----------------
// Spinner Control
//----------------
- (void) startWaitingForServer{
    _isWaiting = YES;
    [_spinner startAnimating];
}

- (void) stopWaitingForServer{
    _isWaiting = NO;
    [_spinner stopAnimating];
}


//----------------
// Submit reg form
//----------------
- (IBAction)submit:(UIButton *)sender{
    if ([[sender currentTitle] isEqualToString:@"Debug"]){
        [self debugGetUser];
        return;
    }
        
    [self hideKeyboard];
    [self getInput];
    [self putInput];
    if (![self isValidInput])
        return;
    [self register];
}


//-----------------------
// Get and Validate Input
//-----------------------
- (void)getInput{
    _firstName = [self cleanName:_firstNameTxt.text];
    _lastName  = [self cleanName: _lastNameTxt.text];
    _countryCode  = [self cleanNumber: _countryCodeTxt.text];
    _mobileNumber = [self cleanNumber: _mobileNumberTxt.text ];
    _combinedNumber = [NSString stringWithFormat:@"+%@%@", _countryCode, _mobileNumber];
}

- (void) putInput{
    _firstNameTxt.text = _firstName;
    _lastNameTxt.text = _lastName;
    _countryCodeTxt.text = _countryCode;
    _mobileNumberTxt.text = _mobileNumber;
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
    [self startWaitingForServer];
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [hc
                                  GET:@"reg/reg"
                                  parameters:[self userParams]
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      DebugLog(@"register success: %@", responseObject);
                                      [self stopWaitingForServer];
                                      [self didRegister:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DebugLog(@"register fail: %@", error);
                                      [self stopWaitingForServer];
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
    [self startWaitingForServer];
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [hc
                                  GET:@"reg/verify_code"
                                  parameters:[self userParams]
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      DebugLog(@"register success: %@", responseObject);
                                      [self stopWaitingForServer];
                                      [self didReceiveCodeResponse:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DebugLog(@"register fail: %@", error);
                                      [self stopWaitingForServer];
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
[self startWaitingForServer];
TBMHttpClient *hc = [TBMHttpClient sharedClient];
NSURLSessionDataTask *task = [hc
                              GET:@"reg/debug_get_user"
                              parameters:@{@"mobile_number": @"6502453537"}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  DebugLog(@"register success: %@", responseObject);
                                  [self stopWaitingForServer];
                                  [self didReceiveCodeResponse:responseObject];
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  DebugLog(@"register fail: %@", error);
                                  [self stopWaitingForServer];
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
    [self startWaitingForServer];
    [[[TBMFriendGetter alloc] initWithDelegate:self destroyAll:YES] getFriends];
}

- (void) gotFriends{
    [self stopWaitingForServer];
    [self userAndFriendModelsAreSetup];
}

- (void) friendGetterServerError{
    [self stopWaitingForServer];
    [self showGetFriendsServerErrorDialog];
}

//--------
// Dialogs
//--------
- (void) connectionError{
    DebugLog(@"connectionError:");
    NSString *msg = [NSString stringWithFormat:@"Unable to reach the %@ please check your Internet connection and try again.", TBMConfig.appName];
    [self showErrorDialogWithTitle:@"Try Again" msg:msg];
}

- (void) showErrorDialogWithTitle:(NSString *)title msg:(NSString *)msg{
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
    NSString *msg = [NSString stringWithFormat:@"Unable to reach the %@ please check your Internet connection and try again.", TBMConfig.appName];

    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Bad Connection"
                       message:msg
                       delegate:self
                       cancelButtonTitle:@"Try Again"
                       otherButtonTitles:nil];

    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self getFriends];
    };

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

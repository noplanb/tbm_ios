//
//  TBMRegisterViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMRegisterViewController.h"
#import "TBMHttpManager.h"
#import "TBMS3CredentialsManager.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "NBPhoneNumberUtil.h"
#import "OBLogger.h"
#import "TBMTextField.h"
#import "TBMPhoneUtils.h"
#import "UIAlertView+Blocks.h"
#import "TBMAlertController.h"
#import "TBMAlertControllerVisualStyle.h"

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
@property (nonatomic) SDCAlertAction *enterCodeConfirmAlertAction;

@end

@implementation TBMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_registerForm stopWaitingForServer];
    self.registerForm = [[TBMRegisterForm alloc] initWithView:self.view delegate:self];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.61f green:0.75f blue:0.27f alpha:1.0f];
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
    [[TBMHttpManager manager] GET:@"reg/reg"
                        parameters:[self userParams]
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [_registerForm stopWaitingForServer];
                               [self didRegister:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [_registerForm stopWaitingForServer];
                               [self connectionError];
                           }];
}

- (NSDictionary *)userParams{
    NSMutableDictionary *r = [[NSMutableDictionary alloc] init];
    [r setObject:@"ios" forKey:SERVER_PARAMS_USER_DEVICE_PLATFORM_KEY];
    [r setObject:_firstName forKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    [r setObject:_lastName forKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    
    NSString *pn = [TBMPhoneUtils phone:_combinedNumber withFormat:NBEPhoneNumberFormatE164];
    if (pn != nil)
        [r setObject:pn forKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    
    if (_verificationCode != nil)
        [r setObject:_verificationCode forKey:SERVER_PARAMS_USER_VERIFICATION_CODE_KEY];
    
    return r;
}

- (void)didRegister:(NSDictionary *)params{
    if ([TBMHttpManager isSuccess:params]){
        self.auth = [params objectForKey:SERVER_PARAMS_USER_AUTH_KEY];
        self.mkey = [params objectForKey:SERVER_PARAMS_USER_MKEY_KEY];
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
    NSURLCredential * c = [[NSURLCredential alloc] initWithUser:self.mkey
                                                       password:self.auth
                                                    persistence:NSURLCredentialPersistenceForSession];
    [_registerForm startWaitingForServer];
    [[TBMHttpManager managerWithCredential:c] GET:@"reg/verify_code"
                        parameters:[self userParams]
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [_registerForm stopWaitingForServer];
                               [self didReceiveCodeResponse:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [_registerForm stopWaitingForServer];
                               [self connectionError];
                           }];
}

- (void)didReceiveCodeResponse:(NSDictionary *)params{
    if ([TBMHttpManager isSuccess:params]){
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
    [[TBMHttpManager manager] GET:@"reg/debug_get_user"
                        parameters:@{@"mobile_number": self.registerForm.mobileNumber.text}
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [_registerForm stopWaitingForServer];
                               [self didReceiveCodeResponse:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [_registerForm stopWaitingForServer];
                               [self connectionError];
                           }];
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
    [self getS3Credentials];
}

- (void) friendGetterServerError{
    [_registerForm stopWaitingForServer];
    [self showGetFriendsServerErrorDialog];
}

//-------------------
// Get S3 Credentials
//-------------------
- (void) getS3Credentials{
    [_registerForm startWaitingForServer];
    [TBMS3CredentialsManager refreshFromServer:^void (BOOL success){
        [_registerForm stopWaitingForServer];
        if (success){
            [self registrationComplete];
        } else {
            [self showS3ErrorDialog];
        }
    }];
}

//--------
// Dialogs
//--------
- (void) connectionError{
    DebugLog(@"connectionError:");
    [self showErrorDialogWithTitle:@"Try Again" msg:[self badConnectionMessage]];
}

- (void) showErrorDialogWithTitle:(NSString *)title msg:(NSString *)msg {
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleCancel handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void) showVerificationDialog {
    NSString *msg = [NSString stringWithFormat:@"We sent a code via text message to %@.", [TBMPhoneUtils phone:_combinedNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL]];

    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Enter Code" message:msg];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ((TBMAlertControllerVisualStyle *)alert.visualStyle).width, 90.0f)];
    content.backgroundColor = [UIColor clearColor];
    
    UILabel *enterCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, content.frame.size.width, 20.0f)];
    enterCodeLabel.text = @"Enter Code";
    enterCodeLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    enterCodeLabel.textAlignment = NSTextAlignmentCenter;
    [content addSubview:enterCodeLabel];
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(25, 30, content.frame.size.width - 50, 40)];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.backgroundColor = [UIColor whiteColor];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    NSString *fname = tf.font.fontName;
    tf.font = [UIFont fontWithName:fname size:20.0f];
    [content addSubview:tf];
    [tf addTarget:self
                  action:@selector(enterCodeTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleDefault handler:nil]];
    
    self.enterCodeConfirmAlertAction = [SDCAlertAction actionWithTitle:@"Enter" style:SDCAlertActionStyleCancel handler:^(SDCAlertAction *action) {
        _verificationCode = [self cleanNumber:[tf text]];
        [self didEnterCode];
    }];
    self.enterCodeConfirmAlertAction.enabled = NO;
    [alert addAction:self.enterCodeConfirmAlertAction];
    
    [alert.contentView addSubview:content];
    
    [alert presentWithCompletion:nil];
}

-(void)enterCodeTextFieldDidChange:(UITextField *)tf {
    self.enterCodeConfirmAlertAction.enabled = (tf.text.length > 0);
}

- (void) showGetFriendsServerErrorDialog{
    NSString *msg = [self badConnectionMessage];
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:[self badConnectionTitle] message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleCancel handler:^(SDCAlertAction *action) {
        [self getFriends];
    }]];
    [alert presentWithCompletion:nil];
}

- (void) showS3ErrorDialog{
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:[self badConnectionTitle]
                       message:[self badConnectionMessage]
                       delegate:self
                       cancelButtonTitle:@"Try Again"
                       otherButtonTitles:nil];
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self getS3Credentials];
    };
    [av show];
}

- (NSString *)badConnectionMessage{
    return [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", CONFIG_APP_NAME];
}

- (NSString *)badConnectionTitle{
    return @"Bad Connection";
}


//--------------
// Done with reg
//--------------


- (void) registrationComplete{
    [TBMUser getUser].isRegistered = YES;
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

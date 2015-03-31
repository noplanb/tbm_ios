//
//  TBMHomeViewController+Invite.m
//  tbm
//
//  Created by Sani Elfishawy on 9/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Invite.h"
#import "TBMContactsManager.h"
#import "OBLogger.h"
#import "TBMConfig.h"
#import <objc/runtime.h>
#import "TBMPhoneUtils.h"
#import "SDCAlertController.h"
#import "UIAlertView+Blocks.h"
#import "TBMHttpManager.h"
#import "TBMUser.h"
#import "TBMAlertController.h"


@implementation TBMHomeViewController (Invite)

//-----------------------------------------
// Instance variables as associated objects
//-----------------------------------------
// @property fullname
- (void)setFullname:(NSString *)obj {
    objc_setAssociatedObject(self, @selector(fullname), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fullname {
    return (NSString *)objc_getAssociatedObject(self, @selector(fullname));
}
// @property contact
- (void)setContact:(NSDictionary *)obj {
    objc_setAssociatedObject(self, @selector(contact), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSDictionary *)contact {
    return (NSDictionary *)objc_getAssociatedObject(self, @selector(contact));
}
// @property validPhones
- (void)setValidPhones:(NSMutableArray *)obj {
    objc_setAssociatedObject(self, @selector(validPhones), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)validPhones {
    return (NSMutableArray *)objc_getAssociatedObject(self, @selector(validPhones));
}
// @property tableModal
- (void)setTableModal:(TBMTableModal *)obj {
    objc_setAssociatedObject(self, @selector(tableModal), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TBMTableModal *)tableModal {
    return (TBMTableModal *)objc_getAssociatedObject(self, @selector(tableModal));
}
// @property selectedPhone
- (void)setSelectedPhone:(NSString *)obj{
    objc_setAssociatedObject(self, @selector(selectedPhone), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)selectedPhone{
    return (NSString *)objc_getAssociatedObject(self, @selector(selectedPhone));
}
// @property spinner
- (void)setSpinner:(UIActivityIndicatorView *)obj{
    objc_setAssociatedObject(self, @selector(spinner), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIActivityIndicatorView *)spinner{
    return objc_getAssociatedObject(self, @selector(spinner));
}
// @property dimScreenView
- (void)setDimScreenView:(UIView *)obj{
    objc_setAssociatedObject(self, @selector(dimScreenView), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView *)dimScreenView{
    return objc_getAssociatedObject(self, @selector(dimScreenView));
}
// @property friend
- (void)setFriend:(TBMFriend *)obj{
    objc_setAssociatedObject(self, @selector(friend), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TBMFriend *)friend{
    return objc_getAssociatedObject(self, @selector(friend));
}

//----------------
// Invite sequence
//----------------
- (void)invite:(NSString *)fullname{
    OB_INFO(@"invite: %@", fullname);
    [self addViews];
    [self setFriend:nil];

    [self setFullname:fullname];
    [self setContact: [[TBMContactsManager sharedInstance] contactWithFullname:fullname]];

    [self getValidPhones];
    
    if ([self validPhones].count == 0) {
        [self noValidPhonesDialog];
        return;
    }
    
    if ([self validPhones].count == 1){
        [self setSelectedPhone:[[[self validPhones] objectAtIndex:0] objectAtIndex:0]];
        [self handleSelectedPhone];
        return;
    }
    
    [self selectPhoneNumberDialog];
}

- (void)handleSelectedPhone{
    TBMFriend *f = [TBMFriend findWithMatchingPhoneNumber:[self selectedPhone]];
    // If already a friend.
    if (f != nil){
        [self setFriend:f];
        [self connectedDialog];
        return;
    }
    
    [self checkFriendHasApp];
}

- (void)nudge:(TBMFriend *)friend{
    if (friend == nil)
        return;
    
    self.friend = friend;
    self.selectedPhone = self.friend.mobileNumber;
    [self preNudgeDialog];
}

- (void)getValidPhones{
    [self setValidPhones:[[NSMutableArray alloc] init]];
    for (NSDictionary *pObj in [[self contact] objectForKey:kContactsManagerPhonesSetKey]){
        NSString *p = [pObj objectForKey: kContactsManagerPhoneNumberKey];
        DebugLog(@"got phone: %@", p);
        if ([TBMPhoneUtils isValidPhone:p]){
            NSArray *entry = [[NSArray alloc] init];
            NSString *pi = [TBMPhoneUtils phone:p withFormat:NBEPhoneNumberFormatINTERNATIONAL];
            entry = @[pi, [pObj objectForKey:kContactsManagerPhoneTypeKey]];
            [[self validPhones] addObject:entry];
        }
    }
}


//--------
// Dialogs
//--------
- (void)noValidPhonesDialog{
    NSString *title = @"No Mobile Number";
    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts, kill %@, then try again.", [self fullname], [self firstName], CONFIG_APP_NAME];
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void)selectPhoneNumberDialog{
    TBMTableModal *tm = [[TBMTableModal alloc] initWithParentView:self.view title:@"Mobile Phone?" rowData:[self validPhones] delegate:self];
    [self setTableModal: tm];
    [[self tableModal] show];
}

//TableModalDelegate methods
- (void)didSelectRow:(NSInteger)index{
    NSString *p = [[[self validPhones] objectAtIndex:index] objectAtIndex:0];
    [self setSelectedPhone:p];
    [self handleSelectedPhone];
}



//-------------
// Server calls
//-------------
- (void)checkFriendHasApp{
    [self startWaitingForServer];
    [[TBMHttpManager manager] GET:@"invitation/has_app"
                        parameters:@{SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY: [self selectedPhoneE164]}
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               DebugLog(@"invitation/has_app success: %@", responseObject);
                               [self stopWaitingForServer];
                               [self gotHasApp:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               DebugLog(@"invitation/has_app fail: %@", error);
                               [self stopWaitingForServer];
                               [self hasAppServerErrorDialog];
                           }];
}

- (void)gotHasApp:(NSDictionary *)resp{
    if ([self statusIsFailure:resp])
        return;
    
    NSString *hasAppStr = [resp objectForKey:SERVER_PARAMS_FRIEND_HAS_APP_KEY];
    BOOL hasApp = hasAppStr != nil && [hasAppStr isEqualToString:@"true"];
    if (hasApp)
        [self getFriendFromServer];
    else
        [self preSmsDialog];
}

- (void)getFriendFromServer{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params addEntriesFromDictionary:@{
                                      SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY: [self selectedPhone],
                                      SERVER_PARAMS_FRIEND_FIRST_NAME_KEY: [[self contact] objectForKey:kContactsManagerFirstNameKey],
                                      SERVER_PARAMS_FRIEND_LAST_NAME_KEY: [[self contact] objectForKey:kContactsManagerLastNameKey],
                                      }];
  
    [self startWaitingForServer];
    [[TBMHttpManager manager] GET:@"invitation/invite"
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id responseObject)  {
                                    [self stopWaitingForServer];
                                    [self gotFriend:responseObject];
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [self stopWaitingForServer];
                                    [self getFriendServerErrorDialog];
                                }];
}


- (void) gotFriend:(NSDictionary *)params{
    if ([self statusIsFailure:params])
        return;
    
    [TBMFriend createOrUpdateWithServerParams:params complete:^(TBMFriend *friend) {
        [self setFriend: friend];
        [self connectedDialog];
    }];
}

- (void) connectedDialog{
    NSString *msg = [NSString stringWithFormat:@"You and %@ are connected.\n\nRecord a welcome %@ to %@ now.", [self firstName], CONFIG_APP_NAME, [self firstName]];
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Connected!" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self.gridViewController moveFriendToGrid:[self friend]];
    }]];
    [alert presentWithCompletion:nil];
}

//----------------------------------
// SMS dialog and sending invite sms
//----------------------------------
- (void) preNudgeDialog{
    NSString *msg = [NSString stringWithFormat:@"%@ still hasn't installed %@. Send them the link again.", self.friend.firstName,  CONFIG_APP_NAME];
    NSString *title = [NSString stringWithFormat:@"Nudge %@", self.friend.firstName];
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Send" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self smsDialog];
    }]];
    [alert presentWithCompletion:nil];
}

- (void) preSmsDialog{
    NSString *msg = [NSString stringWithFormat:@"%@ has not installed %@ yet. Send them a link!", [self firstName], CONFIG_APP_NAME];

    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Invite" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Send" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self smsDialog];
    }]];
    [alert presentWithCompletion:nil];
}

- (void)smsDialog{
    if (![MFMessageComposeViewController canSendText]){
        [self cantSendSmsError];
        return;
    }
    
    MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
    mc.messageComposeDelegate = self;
    
    mc.recipients = @[[self selectedPhoneE164]];
    mc.body = [NSString stringWithFormat:@"I sent you a message on %@. Get the app: %@%@", CONFIG_APP_NAME, CONFIG_INVITE_BASE_URL_STRING, [TBMUser getUser].mkey];
    [self startWaitingForServer];
    [self presentViewController:mc animated:YES completion:^{
        [self stopWaitingForServer];
        NSLog(@"presented sms controller");
    }];
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result{
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent){
            OB_INFO(@"Invite Sms Sent");
            if ([self friend] == nil)
                [self getFriendFromServer];
        }
        
        if (result == MessageComposeResultCancelled){
            OB_WARN(@"messageComposeViewController: canceled");
            [self cantSendSmsError];
        }
        
        if (result == MessageComposeResultFailed){
            OB_WARN(@"messageComposeViewController: failed");
            [self cantSendSmsError];
        }
    }];
}


//---------------------
// Add and remove views
//---------------------
- (void)addViews{
    [self addSpinner];
    [self addDimScreen];
}

- (void)addSpinner{
    if ([self spinner] != nil)
        return;
    
    CGSize screen = self.view.frame.size;
    CGRect f = CGRectMake((screen.width/2) - 50, (screen.height/2) - 50, 100, 100);
    [self setSpinner:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
    [self spinner].frame = f;
    [[self spinner] stopAnimating];
    [self.view addSubview:[self spinner]];
}

- (void)addDimScreen{
    if ([self dimScreenView] != nil)
        return;
    
    DebugLog(@"Adding dim screen");
    [self setDimScreenView:[[UIView alloc] initWithFrame:self.view.frame]];
    [[self dimScreenView] setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [self dimScreenView].hidden = YES;
    [self.view addSubview:[self dimScreenView]];
}

//-------------------
// Waiting for server
//-------------------
- (void)startWaitingForServer{
    DebugLog(@"Start Waiting for Server");
    [self.view bringSubviewToFront:[self dimScreenView]];
    [self.view bringSubviewToFront:[self spinner]];
    [self dimScreenView].hidden = NO;
    [[self spinner] startAnimating];
}

- (void)stopWaitingForServer{
    [[self spinner] stopAnimating];
    [self dimScreenView].hidden = YES;
}


//--------------
// Error Dialogs
//--------------
- (BOOL) statusIsFailure:(NSDictionary *)resp{
    NSString *status = [resp objectForKey:SERVER_PARAMS_STATUS_KEY];
    if ([status isEqualToString:@"failure"]){
        [self showFailureMessageFromServer:resp];
        return YES;
    }
    return NO;
}

- (void) showFailureMessageFromServer:(NSDictionary *)failure{
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:[failure objectForKey:SERVER_PARAMS_ERROR_TITLE_KEY]
                                                                     message:[failure objectForKey:SERVER_PARAMS_ERROR_MSG_KEY]];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void) hasAppServerErrorDialog{
    TBMAlertController *alert = [self serverErrorAlert];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self checkFriendHasApp];
    }]];
    
    [alert presentWithCompletion:nil];
}

- (void) getFriendServerErrorDialog{
    TBMAlertController *alert = [self serverErrorAlert];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self getFriendFromServer];
    }]];
    
    [alert presentWithCompletion:nil];
}

- (TBMAlertController *)serverErrorAlert{
    NSString *msg = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", CONFIG_APP_NAME];

    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Bad Connection" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleCancel handler:nil]];
    
    return alert;
}

- (void)cantSendSmsError{
    NSString *msg = [NSString stringWithFormat:@"It looks like you can't or didn't send a link by text. Perhaps you can just call or email %@ and tell them about %@.", [self fullname], CONFIG_APP_NAME];
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Didn't Send Link" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}


//------------
// Convenience
//------------
- (NSString *)firstName{
    return [[self contact] objectForKey:kContactsManagerFirstNameKey];
}

- (NSString *)lastName{
    return [[self contact] objectForKey:kContactsManagerLastNameKey];
}

- (NSString *)selectedPhoneE164{
    return [TBMPhoneUtils phone:[self selectedPhone] withFormat:NBEPhoneNumberFormatE164];
}

@end

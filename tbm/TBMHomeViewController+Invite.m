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
#import "TBMHttpClient.h"
#import "TBMUser.h"


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

//----------------
// Invite sequence
//----------------
- (void)invite:(NSString *)fullname{
    OB_INFO(@"invite: %@", fullname);
    [self setFullname:fullname];
    [self setContact: [[TBMContactsManager sharedInstance] contactWithFullname:fullname]];
    
    [self getValidPhones];
    
    if ([self validPhones].count == 0) {
        [self noValidPhonesDialog];
        return;
    }
    
    if ([self validPhones].count == 1){
        [self setSelectedPhone:[[self validPhones] objectAtIndex:0]];
        [self getFriendFromServer];
    }
    
    [self selectPhoneNumberDialog];
}


- (void)getValidPhones{
    [self setValidPhones:[[NSMutableArray alloc] init]];
    for (NSDictionary *pObj in [[self contact] objectForKey:kContactsManagerPhonesKey]){
        NSString *p = [pObj objectForKey: kContactsManagerPhoneNumberKey];
        if ([TBMPhoneUtils isValidPhone:p]){
            NSArray *entry = [[NSArray alloc] init];
            NSString *pi = [TBMPhoneUtils phone:p withFormat:NBEPhoneNumberFormatINTERNATIONAL];
            entry = @[pi, [pObj objectForKey:kContactsManagerPhoneTypeKey]];
            [[self validPhones] addObject:entry];
        }
    }
}

- (void)noValidPhonesDialog{
    NSString *title = @"No Mobile Number";
    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts, kill %@, then try again.", [self fullname], [self fullname], CONFIG_APP_NAME];
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
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
    [self getFriendFromServer];
}

- (void)getFriendFromServer{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params addEntriesFromDictionary:@{
                                      SERVER_PARAMS_USER_AUTH_KEY: [TBMUser getUser].auth,
                                      SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY: [self selectedPhone],
                                      SERVER_PARAMS_FRIEND_FIRST_NAME_KEY: [[self contact] objectForKey:kContactsManagerFirstNameKey],
                                      SERVER_PARAMS_FRIEND_LAST_NAME_KEY: [[self contact] objectForKey:kContactsManagerLastNameKey],
                                      }];
  
    
    
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    [[self spinner] startAnimating];
    NSURLSessionDataTask *task = [hc
                                  GET:@"invitation/invite"
                                  parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      DebugLog(@"getFriend success: %@", responseObject);
                                      [[self spinner] stopAnimating];
                                      [self gotFriend:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DebugLog(@"register fail: %@", error);
                                      [[self spinner] stopAnimating];
                                      [self getFriendServerErrorDialog];
                                  }];
    [task resume];
}

- (void) gotFriend:(NSDictionary *)params{
    
}




//---------------------
// Add and remove views
//---------------------
- (void)addViews{
    [self addSpinner];
}

- (void)removeViews{
    [self removeSpinner];
}

- (void)addSpinner{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    CGRect f;
    f.origin.x = screen.width/2 - 50;
    f.origin.y = screen.height/2 -50;
    f.size.width = 100;
    f.size.height = 100;
    [self setSpinner:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    [self spinner].frame = f;
    [self.view addSubview:[self spinner]];
    [[self spinner] stopAnimating];
}

- (void)removeSpinner{
    for (UIView *v in self.view.subviews){
        if ([v isEqual:[self spinner]])
            [v removeFromSuperview];
    }
}


//-------------------------
// Connection error dialogs
//-------------------------
- (void) getFriendServerErrorDialog{
    NSString *msg = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", CONFIG_APP_NAME];
    
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Bad Connection"
                       message:msg
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       otherButtonTitles:@"Try Again", nil];
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
            [self getFriendFromServer];
    };
    [av show];
}



@end

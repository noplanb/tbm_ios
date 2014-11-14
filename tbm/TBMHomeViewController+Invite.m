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
- (void)setValidPhones:(NSMutableSet *)obj {
    objc_setAssociatedObject(self, @selector(validPhones), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableSet *)validPhones {
    return (NSMutableSet *)objc_getAssociatedObject(self, @selector(validPhones));
}



- (void)invite:(NSString *)fullname{
    [self setFullname:fullname];
    [self setContact: [[TBMContactsManager sharedInstance] contactWithFullname:fullname]];
    
    [self getValidPhones];
    
    if ([self validPhones].count == 0) {
        [self noValidPhonesDialog];
        return;
    }
    
    if ([self validPhones].count == 1){
        [self sendLinkDialog];
        return;
    }
    
    [self selectPhoneNumberDialog];
}


- (void)getValidPhones{
    [self setValidPhones:[[NSMutableSet alloc] init]];
    for (NSDictionary *pObj in [[self contact] objectForKey:kContactsManagerPhonesKey]){
        NSString *p = [pObj objectForKey: kContactsManagerPhoneNumberKey];
        if ([TBMPhoneUtils isValidPhone:p])
            [[self validPhones] addObject:pObj];
    }
}

- (void)noValidPhonesDialog{
    NSString *title = @"No Mobile Number";
    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts, kill %@, then try again.", [self fullname], [self fullname], CONFIG_APP_NAME];
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
}

- (void)selectPhoneNumberDialog{
    // use https://github.com/sberrevoets/SDCAlertView
}

- (void)sendLinkDialog{
    
}
@end

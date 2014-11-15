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
#import "UIView+SDCAutoLayout.h"


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
// @property selectPhoneTableDelegate
- (void)setSptDelegate:(TBMSelectPhoneTableDelegate *)obj {
    objc_setAssociatedObject(self, @selector(sptDelegate), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TBMSelectPhoneTableDelegate *)sptDelegate {
    return (TBMSelectPhoneTableDelegate *)objc_getAssociatedObject(self, @selector(sptDelegate));
}


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

- (void)sendLinkDialog{
    
}

- (void)selectPhoneNumberDialog{
    NSString *title = [NSString stringWithFormat:@"%@'s mobile?", [[self contact] objectForKey:kContactsManagerFirstNameKey]];
    SDCAlertController *sa = [SDCAlertController alertControllerWithTitle:title message:nil preferredStyle:SDCAlertControllerStyleAlert];

    CGRect f;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = sa.view.frame.size.width;
    f.size.height = 200;
    UITableView *tv = [[UITableView alloc] initWithFrame:f];
    
    // I have to do this delegate class stupidity becuase bench is another category of HomeViewController which is already a TableViewDelegate
    // and there wasnt a cleaner way to keep them from stomping on each other as they are visible across categories.
    [self setSptDelegate: [[TBMSelectPhoneTableDelegate alloc] initWithContact:[self contact] delegate:self]];
    [tv setDelegate:[self sptDelegate]];
    [tv setDataSource:[self sptDelegate]];
    [sa.contentView addSubview:tv];
    [tv sdc_setMaximumWidthToSuperviewWidth];

    [sa presentWithCompletion:nil];
}

- (void)didClickOnPhoneObject:(NSDictionary *)phoneObject{
    DebugLog(@"%@", phoneObject);
}


@end

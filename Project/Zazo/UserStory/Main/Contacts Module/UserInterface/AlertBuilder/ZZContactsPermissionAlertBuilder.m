//
//  ZZContactsPermissionAlertBuilder.m
//  Zazo
//
//  Created by ANODA on 9/24/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZContactsPermissionAlertBuilder.h"
#import "ZZAlertBuilder.h"

@implementation ZZContactsPermissionAlertBuilder

+ (void)showNeedAccessForAddressBookAlert
{
    NSString *text = NSLocalizedString(@"menu.need-addressbook-access.alert.text", @"");

    [ZZAlertBuilder presentAlertWithTitle:@"Sorry" details:text cancelButtonTitle:@"OK"];
}

@end

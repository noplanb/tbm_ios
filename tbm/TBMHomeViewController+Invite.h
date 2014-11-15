//
//  TBMHomeViewController+Invite.h
//  tbm
//
//  Created by Sani Elfishawy on 9/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "TBMSelectPhoneTableDelegate.h"


@interface TBMHomeViewController (Invite) <TBMSelectPhoneTableCallback>
- (void)invite:(NSString *)fullname;
@end

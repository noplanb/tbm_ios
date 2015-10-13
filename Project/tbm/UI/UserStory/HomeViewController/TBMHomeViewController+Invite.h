//
//  TBMHomeViewController+Invite.h
//  tbm
//
//  Created by Sani Elfishawy on 9/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "TBMTableModal.h"

@class TBMFriend;

@interface TBMHomeViewController (Invite) <MFMessageComposeViewControllerDelegate>

- (void)invite:(NSString *)fullname;
- (void)nudge:(TBMFriend *)friend;

@end

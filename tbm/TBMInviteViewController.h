//
//  TBMInviteViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 12/16/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMHomeViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "TBMTableModal.h"


@interface TBMInviteViewController : UIViewController <TBMTableModalDelegate, MFMessageComposeViewControllerDelegate>
+ (TBMInviteViewController *)sharedInstance;
- (void)invite:(NSString *)fullname;
- (void)nudge:(TBMFriend *)friend;
@end

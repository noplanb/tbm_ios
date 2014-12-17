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


@interface TBMHomeViewController (Invite) <TBMTableModalDelegate, MFMessageComposeViewControllerDelegate>
- (void)invite:(NSString *)fullname;
@end

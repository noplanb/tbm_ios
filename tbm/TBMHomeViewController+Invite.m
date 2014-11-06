//
//  TBMHomeViewController+Invite.m
//  tbm
//
//  Created by Sani Elfishawy on 9/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Invite.h"
#import "TBMHomeViewController.h"
#import "OBLogger.h"
#import "TBMConfig.h"
#import "TBMUser.h"

@implementation TBMHomeViewController (Invite)

- (void)setupInvite{
    OB_INFO(@"setupInvite");
//    for (UIView *view in [self inactiveFriendViews]){
//        UITapGestureRecognizer *plusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(plusTapped:)];
//        [view setUserInteractionEnabled:YES];
//        [view addGestureRecognizer:plusGesture];
//    }
}

- (void)plusTapped:(id)sender{
    OB_INFO(@"plusTapped");
    NSString *msg = [NSString stringWithFormat:@"To add a friend send us an email.\n\nWhy?\n\n%@ is in private testing. Invitations require approval.", CONFIG_APP_NAME];
    [[[UIAlertView alloc] initWithTitle:@"Invite" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        OB_INFO(@"Compose Invite Email");
        if ([MFMailComposeViewController canSendMail]){
            [self sendMail];
        } else {
            [self cantSendMailAlert];
        }
    }
}

- (void)sendMail{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject: [NSString stringWithFormat:@"%@ Invite Request", CONFIG_APP_NAME]];
    [controller setToRecipients:[NSArray arrayWithObjects:@"elfishawy.sani@gmail.com",nil]];
    NSString *body = [NSString stringWithFormat:@"Provide name and phone of invitee:\n\nFull name:\n\nPhone with area:\n\n\n\n%@", [TBMUser getUser].mkey];
    [controller setMessageBody:body isHTML:NO];
    if (controller)
        [self presentViewController:controller animated:YES completion:nil];
}

- (void)cantSendMailAlert{
    NSString *msg = @"Please send an email to sani@sbcglobal.net with the fullname, phone number, and email of your invitee.";
    [[[UIAlertView alloc] initWithTitle:@"Invite" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil] show];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    OB_INFO(@"mailComposeController:didFinishWithResult:");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

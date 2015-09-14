//
//  ANEmailPresenter.m
//  Zazo
//
//  Created by ANODA on 1/23/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANMessagesWireframe.h"
#import "ANMessageDomainModel.h"

@interface ANMessagesWireframe ()
<
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UINavigationControllerDelegate
>

@property (nonatomic, copy) ANMessageCompletionBlock messageCompletion;
@property (nonatomic, copy) ANEmailCompletionBlock emailCompletion;

@end

@implementation ANMessagesWireframe


#pragma mark - Emails

- (void)presentEmailControllerFromViewController:(UIViewController*)vc
                                       withModel:(ANMessageDomainModel*)model
                                      completion:(ANEmailCompletionBlock)completion
{
    self.emailCompletion = [completion copy];
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    [composer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail])
    {
        if (!ANIsEmpty(model.recipients))
        {
            [composer setToRecipients:model.recipients];
        }
        if (!ANIsEmpty(model.title))
        {
            [composer setSubject:model.title];
        }
        
        if (!ANIsEmpty(model.message))
        {
            [composer setMessageBody:model.message isHTML:model.isHTMLMessage];
        }
        
        if (!ANIsEmpty(model.image))
        {
            NSData* imageData = UIImagePNGRepresentation(model.image);
            [composer addAttachmentData:imageData mimeType:@"png" fileName:@"image"];
        }
        
        composer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        composer.navigationBar.tintColor = [UIColor whiteColor];
        ANDispatchBlockToMainQueue(^{
            [vc presentViewController:composer animated:YES completion:nil];
        });
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"common.error", nil)
                                    message:NSLocalizedString(@"error.mail.no-avariable-email-client", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"common.ok", nil)
                          otherButtonTitles:nil, nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if (self.emailCompletion)
    {
        self.emailCompletion(result);
    }
    ANDispatchBlockToMainQueue(^{
        controller.mailComposeDelegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}


#pragma mark - Messages

- (void)presentMessageControllerFromViewController:(UIViewController*)vc
                                         withModel:(ANMessageDomainModel*)model
                                        completion:(ANMessageCompletionBlock)completion
{
    self.messageCompletion = [completion copy];
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        
        if (!ANIsEmpty(model.recipients))
        {
            [messageController setRecipients:model.recipients];
        }
        if (!ANIsEmpty(model.title))
        {
            [messageController setSubject:model.title];
        }
        
        if (!ANIsEmpty(model.message))
        {
            [messageController setBody:model.message];
        }
        
        messageController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        messageController.navigationBar.tintColor = [UIColor whiteColor];
        
        ANDispatchBlockToMainQueue(^{
            [vc presentViewController:messageController animated:YES completion:nil];
        });
    }
    else
    {
        self.messageCompletion(kApplicationCannotSendMessage);
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    ANDispatchBlockToMainQueue(^{
        controller.messageComposeDelegate = nil;
        [controller dismissViewControllerAnimated:YES completion:^{
            if (self.messageCompletion)
            {
                self.messageCompletion(result);
            }
        }];
    });
}

@end

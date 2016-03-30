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
@property (nonatomic, copy) ZZSharingCompletionBlock sharingCompletion;

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
        composer.navigationBar.tintColor = [ZZColorTheme shared].tintColor;
        
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

- (void)presentSharingControllerFromViewController:(UIViewController*)vc
                                         withModel:(ANMessageDomainModel*)model
                                        completion:(ZZSharingCompletionBlock)completion
{
    self.sharingCompletion = [completion copy];
    
    NSMutableArray *items = [NSMutableArray new];
    
    if (!ANIsEmpty(model.message))
    {
        [items addObject:model.message];
    }
    
    if (!ANIsEmpty(model.image))
    {
        [items addObject:model.image];
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[]];
 
    if (IOS8_OR_HIGHER)
    {
        controller.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError)
        {
            if (self.sharingCompletion) {
                self.sharingCompletion(completed);
            }
        };
    }
    else
    {
        controller.completionHandler = ^(NSString * __nullable activityType, BOOL completed)
        {
            if (self.sharingCompletion) {
                self.sharingCompletion(completed);
            }
        };
    }
    
    if ([controller respondsToSelector:@selector(popoverPresentationController)])
    {
        // On iPad the activity view controller will be displayed as a popover using the new UIPopoverPresentationController, it requires that you specify an anchor point for the presentation of the popover using one of the three following properties: barButtonItem, sourceView, sourceRect

        controller.popoverPresentationController.sourceView = vc.view;
    }
    
    ANDispatchBlockToMainQueue(^{
        
        [vc presentViewController:controller animated:YES completion:nil];
    });
}

@end

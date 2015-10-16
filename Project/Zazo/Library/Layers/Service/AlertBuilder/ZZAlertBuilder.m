//
//  ZZAlertBuilder.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZAlertBuilder.h"
#import "TBMAlertController.h"

@implementation ZZAlertBuilder

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
{
    [self presentAlertWithTitle:title
                        details:details
              cancelButtonTitle:@"OK"
              actionButtonTitle:nil
                         action:nil];
}

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
            actionButtonTitle:(NSString*)actionButtonTitle
                       action:(ANCodeBlock)completion
{
    [self presentAlertWithTitle:title
                        details:details
              cancelButtonTitle:cancelTitle
             cancelButtonAction:nil
              actionButtonTitle:actionButtonTitle
                         action:completion];
}

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
           cancelButtonAction:(ANCodeBlock)cancelAction
            actionButtonTitle:(NSString*)actionButtonTitle
                       action:(ANCodeBlock)completion
{
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:[NSObject an_safeString:title]
                                                                     message:[NSObject an_safeString:details]];
    
    if (!ANIsEmpty(cancelTitle))
    {
        [alert addAction:[SDCAlertAction actionWithTitle:cancelTitle
                                                   style:SDCAlertActionStyleCancel
                                                 handler:^(SDCAlertAction *action) {
                                                     if (cancelAction)
                                                     {
                                                        cancelAction();
                                                     }
                                                 }]];
    }
    
    if (!ANIsEmpty(actionButtonTitle))
    {
        [alert addAction:[SDCAlertAction actionWithTitle:actionButtonTitle
                                                   style:SDCAlertActionStyleDefault
                                                 handler:^(SDCAlertAction *action) {
                                                     if (completion)
                                                     {
                                                         completion();
                                                     }
        }]];
    }
    
    if (ANIsEmpty(cancelTitle) && ANIsEmpty(actionButtonTitle))
    {
        cancelTitle = @"OK";
    }

    ANDispatchBlockToMainQueue(^{
       [alert presentWithCompletion:nil];
    });
}

@end

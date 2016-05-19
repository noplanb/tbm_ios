//
//  ZZAlertBuilder.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZAlertBuilder.h"

@implementation ZZAlertBuilder

+ (ZZAlertController *)badConnectionAlert
{
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    
    NSString *badConnectionMessage =
    [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];
    
    NSString *title = @"Bad Connection";
    
    return [ZZAlertController alertControllerWithTitle:title message:badConnectionMessage];
}

+ (void)presentAlertWithTitle:(NSString *)title
                      details:(NSString *)details
            cancelButtonTitle:(NSString *)cancelTitle
{
    [self presentAlertWithTitle:title
                        details:details
              cancelButtonTitle:@"OK"
              actionButtonTitle:nil
                         action:nil];
}

+ (void)presentAlertWithTitle:(NSString *)title
                      details:(NSString *)details
            cancelButtonTitle:(NSString *)cancelTitle
            actionButtonTitle:(NSString *)actionButtonTitle
                       action:(ANCodeBlock)completion
{
    [self presentAlertWithTitle:title
                        details:details
              cancelButtonTitle:cancelTitle
             cancelButtonAction:nil
              actionButtonTitle:actionButtonTitle
                         action:completion];
}

+ (void)presentAlertWithTitle:(NSString *)title
                      details:(NSString *)details
            cancelButtonTitle:(NSString *)cancelTitle
           cancelButtonAction:(ANCodeBlock)cancelAction
            actionButtonTitle:(NSString *)actionButtonTitle
                       action:(ANCodeBlock)completion
{
    ZZAlertController *alert = [self alertWithTitle:title
                                            details:details
                                  cancelButtonTitle:cancelTitle
                                 cancelButtonAction:cancelAction
                                  actionButtonTitle:actionButtonTitle
                                             action:completion];

    [self presentAlert:(ZZAlertController *)alert];
}

+ (ZZAlertController *)alertWithTitle:(NSString *)title
                              details:(NSString *)details
                    cancelButtonTitle:(NSString *)cancelTitle
                   cancelButtonAction:(ANCodeBlock)cancelAction
                    actionButtonTitle:(NSString *)actionButtonTitle
                               action:(ANCodeBlock)completion
{
    ZZAlertController *alert = [ZZAlertController alertControllerWithTitle:[NSObject an_safeString:title]
                                                                   message:[NSObject an_safeString:details]];

    if (!ANIsEmpty(cancelTitle))
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *action) {
                                                     if (cancelAction)
                                                     {
                                                         cancelAction();
                                                     }
                                                 }]];
    }

    if (!ANIsEmpty(actionButtonTitle))
    {

        [alert addAction:[UIAlertAction actionWithTitle:actionButtonTitle
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
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

    return alert;
}

+ (ZZAlertController *)alertWithTitle:(NSString *)title
                              details:(NSString *)details
                    cancelButtonTitle:(NSString *)cancelTitle
                   cancelButtonAction:(ANCodeBlock)cancelAction
                              actions:(NSArray <UIAlertAction *> *)actions
{
    ZZAlertController *alert =
            [self alertWithTitle:title
                         details:details
               cancelButtonTitle:cancelTitle
              cancelButtonAction:cancelAction
               actionButtonTitle:nil
                          action:nil];

    [actions enumerateObjectsUsingBlock:^(UIAlertAction *_Nonnull action, NSUInteger idx, BOOL *_Nonnull stop) {
        [alert addAction:action];
    }];

    return alert;
}

+ (ZZAlertController *)alertWithTitle:(NSString *)title
{
    ZZAlertController *alert = [ZZAlertController alertControllerWithTitle:[NSObject an_safeString:title]
                                                                   message:@""];

    return alert;
}

+ (void)presentAlertWithTitle:(NSString *)title
                      details:(NSString *)details
            cancelButtonTitle:(NSString *)cancelTitle
           cancelButtonAction:(ANCodeBlock)cancelAction
                      actions:(NSArray <UIAlertAction *> *)actions
{
    ZZAlertController *alert =
            [self alertWithTitle:title
                         details:details
               cancelButtonTitle:cancelTitle
              cancelButtonAction:cancelAction
                         actions:actions];

    [self presentAlert:(ZZAlertController *)alert];

}

+ (void)presentAlert:(ZZAlertController *)alert
{
    ANDispatchBlockToMainQueue(^{
        [alert presentWithCompletion:nil];
    });
}

@end

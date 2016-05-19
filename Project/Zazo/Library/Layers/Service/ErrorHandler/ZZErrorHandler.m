//
//  ZZErrorHandler.m
//  Zazo
//
//  Created by ANODA on 8/17/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZErrorHandler.h"
#import "ZZAlertController.h"

@implementation ZZErrorHandler

+ (void)showErrorAlertWithLocalizedTitle:(NSString *)title message:(NSString *)message
{
    NSString *okButton = NSLocalizedString(@"common.ok", nil);

    ANDispatchBlockToMainQueue(^{
        ZZAlertController *alert = [ZZAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                       message:NSLocalizedString(message, nil)];
        
        [alert addAction:[UIAlertAction actionWithTitle:okButton
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
            [alert dismissWithCompletion:nil];
        }]];
        
        [alert presentWithCompletion:nil];
    });
}

+ (void)showAlertWithError:(NSError *)error
{
    [self showErrorAlertWithLocalizedTitle:error.localizedFailureReason message:error.localizedDescription];
}

@end

//
//  ZZErrorHandler.m
//  Zazo
//
//  Created by ANODA on 8/17/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZErrorHandler.h"
#import "TBMAlertController.h"

@implementation ZZErrorHandler

+ (void)showErrorAlertWithLocalizedTitle:(NSString*)title message:(NSString *)message
{
    NSString *okButton = NSLocalizedString(@"common.ok", nil);
    
    ANDispatchBlockToMainQueue(^{
        TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                         message:NSLocalizedString(message, nil)];
        [alert addAction:[SDCAlertAction actionWithTitle:okButton style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
            [alert dismissWithCompletion:nil];
        }]];
        [alert presentWithCompletion:nil];
    });
}

+ (void)showAlertWithError:(NSError*)error
{
    [self showErrorAlertWithLocalizedTitle:error.localizedFailureReason message:error.localizedDescription];
}

@end

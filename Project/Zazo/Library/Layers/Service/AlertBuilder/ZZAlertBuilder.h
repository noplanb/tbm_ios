//
//  ZZAlertBuilder.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//
#import "ZZAlertController.h"


@interface ZZAlertBuilder : NSObject

+ (void)presentAlertWithTitle:(NSString*)title details:(NSString*)details cancelButtonTitle:(NSString*)cancelTitle;

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
            actionButtonTitle:(NSString*)actionButtonTitle
                       action:(ANCodeBlock)completion;

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
           cancelButtonAction:(ANCodeBlock)cancelAction
            actionButtonTitle:(NSString*)actionButtonTitle
                       action:(ANCodeBlock)completion;

+ (ZZAlertController *)alertWithTitle:(NSString*)title
                               details:(NSString*)details
                     cancelButtonTitle:(NSString*)cancelTitle
                    cancelButtonAction:(ANCodeBlock)cancelAction
                     actionButtonTitle:(NSString*)actionButtonTitle
                                action:(ANCodeBlock)completion;

+ (ZZAlertController *)alertWithTitle:(NSString*)title
                               details:(NSString*)details
                     cancelButtonTitle:(NSString*)cancelTitle
                    cancelButtonAction:(ANCodeBlock)cancelAction
                               actions:(NSArray <SDCAlertAction *> *)actions;

+ (ZZAlertController *)alertWithTitle:(NSString*)title;

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
           cancelButtonAction:(ANCodeBlock)cancelAction
                      actions:(NSArray <SDCAlertAction *> *)actions;

@end

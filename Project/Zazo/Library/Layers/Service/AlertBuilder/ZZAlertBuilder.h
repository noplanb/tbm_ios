//
//  ZZAlertBuilder.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZAlertBuilder : NSObject

+ (void)presentAlertWithTitle:(NSString*)title details:(NSString*)details cancelButtonTitle:(NSString*)cancelTitle;

+ (void)presentAlertWithTitle:(NSString*)title
                      details:(NSString*)details
            cancelButtonTitle:(NSString*)cancelTitle
            actionButtonTitle:(NSString*)actionButtonTitle
                       action:(ANCodeBlock)completion;

@end

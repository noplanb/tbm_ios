//
//  ZZAlertController.h
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCAlertController.h"
#import "SDCAlertControllerView.h"

@interface ZZAlertController : UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

// Dismisses alert automatically when application minimized:
- (void)dismissWithApplicationAutomatically;

- (void)dismissWithCompletion:(void (^)(void))completion;
- (void)presentWithCompletion:(void(^)(void))completion;

@end

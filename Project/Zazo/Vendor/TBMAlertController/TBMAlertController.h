//
//  TBMAlertController.h
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCAlertController.h"
#import "SDCAlertControllerView.h"

@interface TBMAlertController : SDCAlertController <SDCAlertControllerViewDelegate>

@property (nonatomic, strong) SDCAlertControllerView *alert;

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message forcePlain:(BOOL)forcePlain;
+ (id)badConnectionAlert;

@end

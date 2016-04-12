//
//  TBMAlertController.m
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"

@interface SDCAlertController (Private)

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(SDCAlertControllerStyle)style;

@end

@interface TBMAlertController ()

@property (nonatomic, assign) BOOL dismissWithApplication;

@end

@implementation TBMAlertController

@dynamic alert;

#pragma mark - Initialization

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    return [[self alloc] initWithTitle:title message:message style:SDCAlertControllerStyleAlert];
}

+ (id)badConnectionAlert
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];

    NSString* badConnectionMessage =
            [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];
    
    NSString* title = @"Bad Connection";
    
    return [self alertControllerWithTitle:title message:badConnectionMessage];
}

#pragma mark - Alert Actions

- (void)alertControllerView:(SDCAlertControllerView *)sender didPerformAction:(SDCAlertAction *)action
{
    if (!action.isEnabled || (self.shouldDismissBlock && !self.shouldDismissBlock(action))) {
        return;
    }
    
    [self dismissWithCompletion:^{
        if (action.handler) {
            action.handler(action);
        }
    }];
}

#pragma mark dismissWithApplication

- (void)dismissWithApplicationAutomatically
{
    if (self.dismissWithApplication)
    {
        return;
    }
    
    self.dismissWithApplication = YES;
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(_appWillDisappearNotification)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
    
}

- (void)_appWillDisappearNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    self.dismissWithApplication = NO;
    [self dismissWithCompletion:nil];
}

@end

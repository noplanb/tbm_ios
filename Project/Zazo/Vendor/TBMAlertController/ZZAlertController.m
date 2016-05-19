//
//  ZZAlertController.m
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZAlertController.h"
#import "UIViewController+ANAdditions.h"

@interface ZZAlertController ()

@property (nonatomic, assign) BOOL dismissWithApplication;

@end

@implementation ZZAlertController

#pragma mark - Initialization

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    return [ZZAlertController alertControllerWithTitle:title
                                               message:message
                                        preferredStyle:UIAlertControllerStyleAlert];
}

- (void)presentWithCompletion:(void(^)(void))completion
{
    UIViewController *currentViewController = [UIViewController zz_currentViewController];
    
    [self presentFromViewController:currentViewController
                  completionHandler:completion];
    
}

- (void)presentFromViewController:(UIViewController *)viewController
                completionHandler:(void (^)(void))completionHandler
{
    [viewController presentViewController:self
                                 animated:YES
                               completion:completionHandler];
}

- (void)dismissWithCompletion:(void (^)(void))completion
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:completion];
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

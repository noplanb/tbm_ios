//
//  ZZStartPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartPresenter.h"
#import "ZZAlertBuilder.h"

@interface ZZStartPresenter ()

@end

@implementation ZZStartPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZStartViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor checkVersionState];
}

#pragma mark - Output

- (void)userRequiresAuthentication
{
    [self.wireframe presentRegistrationController];
}

- (void)userHasAuthentication
{
    if (!self.interactor.isNeedUpdate)
    {
        [self.wireframe presentMenuControllerWithGrid];
    }
}

- (void)applicationIsUpToDate
{

}

- (void)needUpdate:(BOOL)canBeSkipped
{
    NSString* message = canBeSkipped ? [self makeMessageWithQualifier:@"out of date"] : [self makeMessageWithQualifier:@"obsolete"];
    [ZZAlertBuilder presentAlertWithTitle:@"Update Available"
                                  details:message
                        cancelButtonTitle:canBeSkipped ? @"Later" : nil
                       cancelButtonAction:canBeSkipped ? ^{
                           [self.wireframe presentMenuControllerWithGrid];
                       }: nil
                        actionButtonTitle:@"Update" action:^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];
                        }];
}

- (NSString*)makeMessageWithQualifier:(NSString *)q
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
}

- (void)userVersionStateLoadingDidFailWithError:(NSError*)error
{
    
}


#pragma mark - Module Interface


@end

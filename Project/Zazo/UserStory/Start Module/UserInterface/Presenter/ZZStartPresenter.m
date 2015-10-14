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
    [self.interactor checkVersionStateAndSession];
}

#pragma mark - Output

- (void)userRequiresAuthentication
{
    [self.wireframe presentRegistrationController];
}

- (void)needUpdateAndCanSkip:(BOOL)canBeSkipped logged:(BOOL)isLoggedIn
{
    [self _needUpdate:canBeSkipped];
}

- (void)applicationIsUpToDateAndUserLogged:(BOOL)isUserLoggedIn
{
    if (isUserLoggedIn)
    {
        [self _showMenuWithGrid];
    }
}

- (void)userVersionStateLoadingDidFailWithError:(NSError*)error
{

}

#pragma mark Private

- (void)_needUpdate:(BOOL)canBeSkipped
{
    NSString* message = canBeSkipped ? [self _makeMessageWithQualifier:@"out of date"] : [self _makeMessageWithQualifier:@"obsolete"];
    [ZZAlertBuilder presentAlertWithTitle:@"Update Available"
                                  details:message
                        cancelButtonTitle:canBeSkipped ? @"Later" : nil
                       cancelButtonAction:canBeSkipped ? ^{
                           [self _showMenuWithGrid];
                       }: nil
                        actionButtonTitle:@"Update" action:^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];
                        }];
}

- (void)_showMenuWithGrid
{
    [self.wireframe presentMenuControllerWithGrid];
}

- (NSString*)_makeMessageWithQualifier:(NSString *)q
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
}

@end

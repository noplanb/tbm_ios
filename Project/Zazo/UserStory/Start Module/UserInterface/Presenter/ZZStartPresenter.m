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

@property (nonatomic, copy) ANCodeBlock completionBlock;

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

- (void)applicationIsUpToDateAndUserLogged:(BOOL)isUserLoggedIn
{
    if (isUserLoggedIn)
    {
        [self _showMenuWithGrid];
    }
}

#pragma mark Private


- (void)_showMenuWithGrid
{
    [self.wireframe presentMenuControllerWithGrid];
}

- (void)presentNetworkTestController
{
    [self.wireframe presentNetworkTestController];
}

@end

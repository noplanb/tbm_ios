//
//  ZZStartPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartPresenter.h"

@interface ZZStartPresenter ()

@end

@implementation ZZStartPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZStartViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor checkVersion];
}

#pragma mark - Output

- (void)userRequiresAuthentication
{
    [self.wireframe presentRegistrationController];
}

- (void)userHasAuthentication
{
    [self.wireframe presentMenuControllerWithGrid];
}


#pragma mark - Module Interface



@end

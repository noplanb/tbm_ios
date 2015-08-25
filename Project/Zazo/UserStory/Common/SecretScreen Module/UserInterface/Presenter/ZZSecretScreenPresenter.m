//
//  ZZSecretScreenPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenPresenter.h"

@interface ZZSecretScreenPresenter ()

@end

@implementation ZZSecretScreenPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretScreenViewInterface>*)userInterface
{
    self.userInterface = userInterface;
}

- (void)dismissSecretController
{
    [self.wireframe dismissSecretScreenController];
}

#pragma mark - Output




#pragma mark - Module Interface
- (void)presentPushedViewControllerWithType:(ZZPushedScreenType)type
{
    [self.wireframe presentPushedSecretScreenControllerwithType:type];
}

@end

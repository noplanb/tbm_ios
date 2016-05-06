//
//  ZZAuthWireframe.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthWireframe.h"
#import "ZZAuthInteractor.h"
#import "ZZAuthVC.h"
#import "ZZAuthPresenter.h"
#import "ZZGridWireframe.h"
#import "ZZNetworkTestWireframe.h"
#import "ZZMainWireframe.h"
#import "ZZRootWireframe.h"

@interface ZZAuthWireframe ()

@property (nonatomic, strong) ZZAuthPresenter *presenter;
@property (nonatomic, strong) ZZAuthVC *authController;
@property (nonatomic, strong) UINavigationController *presentedController;
@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZAuthWireframe

- (void)presentAuthControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock
{
    self.completionBlock = completionBlock;
    ANDispatchBlockToMainQueue(^{
        UINavigationController *navigationController = [UINavigationController new];
        navigationController.navigationBarHidden = YES;
        window.rootViewController = navigationController;
        [self presentAuthControllerFromNavigationController:navigationController];
    });
}

- (void)presentAuthControllerFromNavigationController:(UINavigationController *)nc
{
    ZZAuthVC *authController = [ZZAuthVC new];
    ZZAuthInteractor *interactor = [ZZAuthInteractor new];
    ZZAuthPresenter *presenter = [ZZAuthPresenter new];

    interactor.output = presenter;

    authController.eventHandler = presenter;

    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:authController];

    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:authController animated:NO];
    });

    self.presenter = presenter;
    self.presentedController = nc;
    self.authController = authController;
}

- (void)dismissAuthController
{
    [self.presentedController popViewControllerAnimated:YES];
}

- (void)presentGridController
{
    ZZMainWireframe *wireframe = [ZZMainWireframe new];
    [wireframe presentMainControllerFromWindow:self.authController.view.window
                                    completion:self.completionBlock];
}

- (void)presentNetworkTestController
{
    ZZNetworkTestWireframe *testWireframe = [ZZNetworkTestWireframe new];
    [testWireframe presentNetworkTestControllerFromWindow:self.authController.view.window];
}

- (void)showSecretScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ZZNeedsToShowSecretScreenNotificationName object:nil];
}

@end

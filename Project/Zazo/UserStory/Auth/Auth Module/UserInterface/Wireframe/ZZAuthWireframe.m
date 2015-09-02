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

@interface ZZAuthWireframe ()

@property (nonatomic, strong) ZZAuthPresenter* presenter;
@property (nonatomic, strong) ZZAuthVC* authController;
@property (nonatomic, strong) UINavigationController* presentedController;

@end

@implementation ZZAuthWireframe

- (void)presentAuthControllerFromWindow:(UIWindow*)window
{
    UINavigationController* navigationController = [UINavigationController new];
    navigationController.navigationBarHidden = YES;
    window.rootViewController = navigationController;
    [self presentAuthControllerFromNavigationController:navigationController];
}

- (void)presentAuthControllerFromNavigationController:(UINavigationController *)nc
{
    ZZAuthVC* authController = [ZZAuthVC new];
    ZZAuthInteractor* interactor = [ZZAuthInteractor new];
    ZZAuthPresenter* presenter = [ZZAuthPresenter new];
    
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

- (void)presentGridModule
{
    ZZMenuWireframe* menuwireframe = [ZZMenuWireframe new];
    [menuwireframe presentMenuControllerFromWindow:self.authController.view.window];
    
//    ZZGridWireframe* wireframe = [ZZGridWireframe new];
//    [wireframe presentGridControllerFromNavigationController:self.presentedController];
}

@end

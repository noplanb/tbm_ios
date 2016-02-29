//
//  ZZStartWireframe.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartWireframe.h"
#import "ZZStartInteractor.h"
#import "ZZStartVC.h"
#import "ZZStartPresenter.h"
#import "ZZAuthWireframe.h"
#import "ZZMenuWireframe.h"
#import "ZZNetworkTestWireframe.h"

@interface ZZStartWireframe ()

@property (nonatomic, strong) ZZStartPresenter* presenter;
@property (nonatomic, strong) ZZStartVC* startController;
@property (nonatomic, strong) UINavigationController* presentedController;
@property (nonatomic, strong) UIWindow* presentedWindow;
@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZStartWireframe

- (void)presentStartControllerFromWindow:(UIWindow*)window completion:(ANCodeBlock)completionBlock
{
    self.completionBlock = completionBlock;
    ZZStartVC* startController = [ZZStartVC new];
    ZZStartInteractor* interactor = [ZZStartInteractor new];
    ZZStartPresenter* presenter = [ZZStartPresenter new];
    
    interactor.output = presenter;
    
    startController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    
    UINavigationController* nc = [UINavigationController new];
    nc.viewControllers = @[startController];
    
    ANDispatchBlockToMainQueue(^{
        window.rootViewController = nc;
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.startController = startController;
    self.presentedWindow = window;
    
    [presenter configurePresenterWithUserInterface:startController];
}

- (void)dismissStartController
{
    [self.presentedController popViewControllerAnimated:YES];
}

- (void)presentMenuControllerWithGrid
{
    ZZMenuWireframe* wireframe = [ZZMenuWireframe new];
    [wireframe presentMenuControllerFromWindow:self.presentedWindow completion:self.completionBlock];
}

- (void)presentRegistrationController
{
    ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
    [wireframe presentAuthControllerFromWindow:self.presentedWindow completion:^{
        self.completionBlock();
        [self.presenter.interactor checkVersionStateForUserLoggedInState:YES];
    }];
}

- (void)presentNetworkTestController
{
     ZZNetworkTestWireframe* testWireframe = [ZZNetworkTestWireframe new];
    [testWireframe presentNetworkTestControllerFromWindow:self.presentedWindow];
}

@end

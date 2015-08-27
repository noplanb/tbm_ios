//
//  ZZMenuWireframe.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuWireframe.h"
#import "ZZMenuInteractor.h"
#import "ZZMenuVC.h"
#import "ZZMenuPresenter.h"
#import "ANDrawerNC.h"
#import "ZZGridWireframe.h"
#import "ZZGridPresenter.h"


@interface ZZMenuWireframe ()

@property (nonatomic, strong) ZZMenuPresenter* presenter;
@property (nonatomic, strong) ZZMenuVC* menuController;
@property (nonatomic, strong) ANDrawerNC* drawerController;

@property (nonatomic, strong) UIViewController* previousController;

@end

@implementation ZZMenuWireframe

- (void)presentMenuControllerFromWindow:(UIWindow *)window
{
    
    ANDispatchBlockToMainQueue(^{
        ZZMenuVC* menuController = [ZZMenuVC new];
        ANDrawerNC* drawerController = [self drawerControllerWithView:menuController.view];
        drawerController.navigationBarHidden = YES;
        ZZMenuInteractor* interactor = [ZZMenuInteractor new];
        ZZMenuPresenter* presenter = [ZZMenuPresenter new];
        
        interactor.output = presenter;
        
        menuController.eventHandler = presenter;
        
        presenter.interactor = interactor;
        presenter.wireframe = self;
        
        [presenter configurePresenterWithUserInterface:menuController];
        
        window.rootViewController = drawerController;
        self.presenter = presenter;
        self.menuController = menuController;
        self.drawerController = drawerController;
        [self presentGridController];
    });
}

#pragma mark - Menu

- (void)presentGridController
{
    ZZGridWireframe* gridWireframe = [ZZGridWireframe new];
    gridWireframe.menuWireFrame = self;
    [gridWireframe presentGridControllerFromNavigationController:self.drawerController];
    self.presenter.menuModuleDelegate = gridWireframe.presenter;
}

#pragma mark - Drawer Controller

- (ANDrawerNC*)drawerControllerWithView:(UIView*)view
{
    NSInteger menuWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth([UIScreen mainScreen].bounds)/4;
    ANDrawerNC* drawerController = [ANDrawerNC drawerWithView:view width:menuWidth direction:ANDrawerOpenDirectionFromRight];
    drawerController.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    drawerController.topPin = ANDrawerTopPinNavigationBar;
    drawerController.avoidKeyboard = YES;
    return drawerController;
}

- (void)toggleMenu
{
    [self.drawerController toggle];
}

- (void)closeMenu
{
    [self.drawerController updateStateToOpened:NO];
}

@end

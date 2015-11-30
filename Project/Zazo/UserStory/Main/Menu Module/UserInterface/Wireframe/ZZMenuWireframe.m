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
#import "ZZGridUIConstants.h"
#import "ZZAddressBookDataProvider.h"

@interface ZZMenuWireframe ()

@property (nonatomic, strong) ZZMenuPresenter* presenter;
@property (nonatomic, strong) ZZMenuVC* menuController;
@property (nonatomic, strong) ANDrawerNC* drawerController;

@property (nonatomic, strong) UIViewController* previousController;
@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZMenuWireframe

- (void)presentMenuControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock
{
    self.completionBlock = completionBlock;
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
    
    ANDispatchBlockToMainQueue(^{
        window.rootViewController = drawerController;
    });
    
    self.presenter = presenter;
    self.menuController = menuController;
    self.drawerController = drawerController;
    [self presentGridController];
}


#pragma mark - Menu

- (void)presentGridController
{
    ZZGridWireframe* gridWireframe = [ZZGridWireframe new];
    gridWireframe.menuWireFrame = self;
    [gridWireframe presentGridControllerFromNavigationController:self.drawerController completion:self.completionBlock];
    self.presenter.menuModuleDelegate = gridWireframe.presenter;
    
}

#pragma mark - Drawer Controller

- (ANDrawerNC*)drawerControllerWithView:(UIView*)view
{
    NSInteger menuWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth([UIScreen mainScreen].bounds)/4;
    ANDrawerNC* drawerController = [ANDrawerNC drawerWithView:view width:menuWidth direction:ANDrawerOpenDirectionFromRight];
    drawerController.useBackground = YES;
    drawerController.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    drawerController.customTopPadding = kGridHeaderViewHeight;
    drawerController.topPin = ANDrawerTopPinCustomOffset;
    drawerController.avoidKeyboard = YES;
    return drawerController;
}

- (void)toggleMenu
{
    [self.presenter menuToggled];
    if ([ZZAddressBookDataProvider isAccessGranted])
    {
        ANDispatchBlockToMainQueue(^{
            [self.presenter.interactor reloadFriends];
            [self.menuController reset];
            [self.drawerController toggle];
        });
    }
}

- (void)closeMenu
{
    ANDispatchBlockToMainQueue(^{
       [self.drawerController updateStateToOpened:NO]; 
    });
}

- (void)attachAdditionalPanGestureToMenu:(UIPanGestureRecognizer*)pan
{
    [self.drawerController attachPanRecognizer:pan];
}

@end

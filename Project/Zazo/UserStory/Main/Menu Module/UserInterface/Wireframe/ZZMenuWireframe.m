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
#import "ZZGridUIConstants.h"
#import "ZZAddressBookDataProvider.h"

@interface ZZMenuWireframe ()

@property (nonatomic, strong, readwrite) UIViewController* menuController;
@property (nonatomic, strong, readwrite) ZZMenuPresenter* presenter;

@end

@implementation ZZMenuWireframe

- (UIViewController *)menuController
{
    if (!_menuController)
    {
        [self _setup];
    }
    return _menuController;
}

- (ZZMenuPresenter *)presenter
{
    if (!_presenter)
    {
        [self _setup];
    }
    return _presenter;
}

- (void)_setup
{
    ZZMenuVC* menuController = [ZZMenuVC new];
    ZZMenuInteractor* interactor = [ZZMenuInteractor new];
    ZZMenuPresenter* presenter = [ZZMenuPresenter new];
    
    interactor.output = presenter;

    menuController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    
    [presenter configurePresenterWithUserInterface:menuController];

    self.presenter = presenter;

    _menuController = menuController;
}

@end

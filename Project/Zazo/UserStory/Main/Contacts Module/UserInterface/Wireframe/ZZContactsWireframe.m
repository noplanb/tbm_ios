//
//  ZZContactsWireframe.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsWireframe.h"
#import "ZZContactsInteractor.h"
#import "ZZContactsVC.h"
#import "ZZContactsPresenter.h"
#import "ZZGridUIConstants.h"
#import "ZZAddressBookDataProvider.h"

@interface ZZContactsWireframe ()

@property (nonatomic, strong, readwrite) UIViewController*contactsController;
@property (nonatomic, strong, readwrite) ZZContactsPresenter * presenter;

@end

@implementation ZZContactsWireframe

- (UIViewController *)contactsController
{
    if (!_contactsController)
    {
        [self _setup];
    }
    return _contactsController;
}

- (ZZContactsPresenter *)presenter
{
    if (!_presenter)
    {
        [self _setup];
    }
    return _presenter;
}

- (void)_setup
{
    ZZContactsVC * menuController = [ZZContactsVC new];
    ZZContactsInteractor * interactor = [ZZContactsInteractor new];
    ZZContactsPresenter * presenter = [ZZContactsPresenter new];
    
    interactor.output = presenter;

    menuController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    
    [presenter configurePresenterWithUserInterface:menuController];

    self.presenter = presenter;

    _contactsController = menuController;
}

@end

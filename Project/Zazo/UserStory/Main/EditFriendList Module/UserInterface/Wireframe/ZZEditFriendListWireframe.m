//
//  ZZEditFriendListWireframe.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListWireframe.h"
#import "ZZEditFriendListInteractor.h"
#import "ZZEditFriendListVC.h"
#import "ZZEditFriendListPresenter.h"

@interface ZZEditFriendListWireframe ()

@property (nonatomic, strong) ZZEditFriendListVC* editFriendListController;
@property (nonatomic, strong) UINavigationController* presentedController;

@end

@implementation ZZEditFriendListWireframe

- (void)presentEditFriendListControllerFromNavigationController:(UINavigationController*)nc
{
    ZZEditFriendListVC* editFriendListController = [ZZEditFriendListVC new];
    ZZEditFriendListInteractor* interactor = [ZZEditFriendListInteractor new];
    ZZEditFriendListPresenter* presenter = [ZZEditFriendListPresenter new];
    
    interactor.output = presenter;
    
    editFriendListController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:editFriendListController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:editFriendListController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.editFriendListController = editFriendListController;
}

- (void)dismissEditFriendListController
{
    ANDispatchBlockToMainQueue(^{
        [self.presentedController popViewControllerAnimated:YES];
    });
}

@end

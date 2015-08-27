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

@property (nonatomic, strong) ZZEditFriendListPresenter* presenter;
@property (nonatomic, strong) ZZEditFriendListVC* editFriendListController;
@property (nonatomic, strong) UIViewController* presentedController;

@end

@implementation ZZEditFriendListWireframe

- (void)presentEditFriendListControllerFromViewController:(UIViewController*)vc
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
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editFriendListController];
        [vc presentViewController:nav animated:YES completion:nil];
    });
    
    self.presenter = presenter;
    self.presentedController = vc;
    self.editFriendListController = editFriendListController;
}

- (void)dismissEditFriendListController
{
    [self.presentedController dismissViewControllerAnimated:YES completion:nil];
}

@end

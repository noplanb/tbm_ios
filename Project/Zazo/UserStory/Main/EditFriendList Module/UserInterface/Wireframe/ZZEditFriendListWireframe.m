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
@property (nonatomic, strong) UIViewController* presentedController;
@property (nonatomic, copy) ANCodeBlock completion;

@end

@implementation ZZEditFriendListWireframe

- (void)presentEditFriendListControllerFromViewController:(UIViewController*)vc withCompletion:(ANCodeBlock)completion
{
    ZZEditFriendListVC* editFriendListController = [ZZEditFriendListVC new];
    ZZEditFriendListInteractor* interactor = [ZZEditFriendListInteractor new];
    ZZEditFriendListPresenter* presenter = [ZZEditFriendListPresenter new];
    
    interactor.output = presenter;
    
    editFriendListController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:editFriendListController];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [vc.view.window.layer addAnimation:transition forKey:nil];
    
    ANDispatchBlockToMainQueue(^{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editFriendListController];
        [vc presentViewController:nav animated:NO completion:nil];
    });
    
    self.presenter = presenter;
    self.presentedController = vc;
    self.editFriendListController = editFriendListController;
    self.completion = [completion copy];
}

- (void)dismissEditFriendListController
{
    if (self.completion)
    {
        self.completion();
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.editFriendListController.view.window.layer addAnimation:transition forKey:nil];
    
    [self.presentedController dismissViewControllerAnimated:NO completion:nil];
}

@end

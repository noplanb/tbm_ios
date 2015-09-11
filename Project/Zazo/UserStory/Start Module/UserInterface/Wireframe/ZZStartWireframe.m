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

@interface ZZStartWireframe ()

@property (nonatomic, strong) ZZStartPresenter* presenter;
@property (nonatomic, strong) ZZStartVC* startController;
@property (nonatomic, strong) UINavigationController* presentedController;

@end

@implementation ZZStartWireframe

- (void)presentStartControllerFromNavigationController:(UINavigationController *)nc
{
    ZZStartVC* startController = [ZZStartVC new];
    ZZStartInteractor* interactor = [ZZStartInteractor new];
    ZZStartPresenter* presenter = [ZZStartPresenter new];
    
    interactor.output = presenter;
    
    startController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:startController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:startController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.startController = startController;
}

- (void)dismissStartController
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end

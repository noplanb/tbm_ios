//
//  ZZDebugStateWireframe.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateWireframe.h"
#import "ZZDebugStateInteractor.h"
#import "ZZDebugStateVC.h"
#import "ZZDebugStatePresenter.h"

@interface ZZDebugStateWireframe ()

@property (nonatomic, strong) ZZDebugStatePresenter* presenter;
@property (nonatomic, strong) ZZDebugStateVC* debugstateController;
@property (nonatomic, strong) UINavigationController* presentedController;

@end

@implementation ZZDebugStateWireframe

- (void)presentDebugStateControllerFromNavigationController:(UINavigationController *)nc
{
    ZZDebugStateVC* debugstateController = [ZZDebugStateVC new];
    ZZDebugStateInteractor* interactor = [ZZDebugStateInteractor new];
    ZZDebugStatePresenter* presenter = [ZZDebugStatePresenter new];
    
    interactor.output = presenter;
    
    debugstateController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:debugstateController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:debugstateController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.debugstateController = debugstateController;
}

- (void)dismissDebugStateController
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end

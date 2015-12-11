//
//  ZZNetworkTestWireframe.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestWireframe.h"
#import "ZZNetworkTestInteractor.h"
#import "ZZNetworkTestVC.h"
#import "ZZNetworkTestPresenter.h"

@interface ZZNetworkTestWireframe ()

@property (nonatomic, strong) ZZNetworkTestPresenter* presenter;
@property (nonatomic, strong) ZZNetworkTestVC* networkTestController;

@end

@implementation ZZNetworkTestWireframe

- (void)presentNetworkTestControllerFromWindow:(UIWindow*)window
{
    ZZNetworkTestVC* networkTestController = [ZZNetworkTestVC new];
    ZZNetworkTestInteractor* interactor = [ZZNetworkTestInteractor new];
    ZZNetworkTestPresenter* presenter = [ZZNetworkTestPresenter new];
    
    interactor.output = presenter;
    
    networkTestController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    
    [presenter configurePresenterWithUserInterface:networkTestController];
    
    ANDispatchBlockToMainQueue(^{
        window.rootViewController = networkTestController;
    });
    
    self.presenter = presenter;
    self.networkTestController = networkTestController;
}

@end

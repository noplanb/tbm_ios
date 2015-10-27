//
//  ZZSecretWireframe.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretWireframe.h"
#import "ZZSecretInteractor.h"
#import "ZZSecretVC.h"
#import "ZZSecretPresenter.h"
#import "OBLogViewController.h"
#import "ZZDebugStateWireframe.h"
#import "ANDebugVC.h"

@interface ZZSecretWireframe ()

@property (nonatomic, strong) ZZSecretPresenter* presenter;
@property (nonatomic, strong) ZZSecretVC* secretController;
@property (nonatomic, strong) UINavigationController* presentedController;

@end

@implementation ZZSecretWireframe

- (void)presentSecretControllerFromNavigationController:(UINavigationController*)nc
{
    ZZSecretVC* secretController = [ZZSecretVC new];
    ZZSecretInteractor* interactor = [ZZSecretInteractor new];
    ZZSecretPresenter* presenter = [ZZSecretPresenter new];
    
    interactor.output = presenter;
    
    secretController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:secretController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:secretController animated:NO];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.secretController = secretController;
}

- (void)dismissSecretController
{
    [self.presentedController popViewControllerAnimated:YES];
}

- (void)presentOrDismissSecretControllerFromNavigationController:(UINavigationController*)nc
{
    if (ANIsEmpty(self.secretController))
    {
        [self presentSecretControllerFromNavigationController:nc];
    }
    else
    {
        if ([nc.topViewController isKindOfClass:[ZZSecretVC class]])
        {
            [self dismissSecretController];
        }
        else
        {
            [self presentSecretControllerFromNavigationController:nc];
        }
    }
}

#pragma mark - Detail Controllers

- (void)presentLogsController
{
    OBLogViewController* vc = [OBLogViewController instance];

    [[[vc rac_signalForSelector:@selector(done:)] take:1] subscribeNext:^(id x) {
        [self.presentedController popViewControllerAnimated:YES];
    }];
    
    [self.presentedController pushViewController:vc animated:YES];
}

- (void)presentStateController
{
    ZZDebugStateWireframe* wireframe = [ZZDebugStateWireframe new];
    [wireframe presentDebugStateControllerFromNavigationController:self.presentedController];
}

- (void)presentDebugController
{
    ANDebugVC* vc = [ANDebugVC new];
    ANDispatchBlockToMainQueue(^{
       [self.presentedController pushViewController:vc animated:YES];
    });
}

@end

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
#import "ZZAuthWireframe.h"
#import "ZZMainWireframe.h"
#import "ZZNetworkTestWireframe.h"
#import "ZZUpdateHelper.h"

@interface ZZStartWireframe ()

@property (nonatomic, strong) ZZStartPresenter* presenter;
@property (nonatomic, strong) UIViewController* startController;
@property (nonatomic, strong) UIWindow* presentedWindow;
@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZStartWireframe

- (void)presentStartControllerFromWindow:(UIWindow*)window completion:(ANCodeBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    UIViewController *startController =
    [UIStoryboard storyboardWithName:@"Launch Screen" bundle:nil].instantiateInitialViewController;
    
    ZZStartInteractor* interactor = [ZZStartInteractor new];
    ZZStartPresenter* presenter = [ZZStartPresenter new];
    
    interactor.output = presenter;
    presenter.interactor = interactor;
    presenter.wireframe = self;
   
    ANDispatchBlockToMainQueue(^{
        window.rootViewController = startController;
    });
    
    self.presenter = presenter;
    self.startController = startController;
    self.presentedWindow = window;
    
    [presenter configurePresenterWithUserInterface:(id)startController];
}

- (void)dismissStartController
{

}

- (void)presentMenuControllerWithGrid
{
    ZZMainWireframe* wireframe = [ZZMainWireframe new];
    [wireframe presentMainControllerFromWindow:self.presentedWindow completion:^{

        [[ZZUpdateHelper shared] checkForUpdates];
        
        if (self.completionBlock)
        {
            self.completionBlock();
        }
    }];
}

- (void)presentRegistrationController
{
    ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
    [wireframe presentAuthControllerFromWindow:self.presentedWindow completion:self.completionBlock];
    [[ZZUpdateHelper shared] checkForUpdates];
}

- (void)presentNetworkTestController
{
     ZZNetworkTestWireframe* testWireframe = [ZZNetworkTestWireframe new];
    [testWireframe presentNetworkTestControllerFromWindow:self.presentedWindow];
}

@end

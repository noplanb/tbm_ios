//
//  ZZRootWireframe.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRootWireframe.h"
#import "ANDebugVC.h"
#import "ZZSecretWireframe.h"
#import "ZZSecretScreenObserveTypes.h"

//TODO: to remove
#import "ZZStartWireframe.h"
#import "ZZSecretScreenController.h"


@interface ZZRootWireframe ()

@property (nonatomic, strong) ZZSecretWireframe* secretWireframe;
@property (nonatomic, strong) ZZSecretScreenController* secretController;
@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZRootWireframe

- (void)showStartViewControllerInWindow:(UIWindow*)window completionBlock:(ANCodeBlock)completionBlock
{
    window.backgroundColor = [UIColor whiteColor];
    self.completionBlock = completionBlock;
    
#ifdef DEBUG_CONTROLLER
    UIViewController* vc = [ANDebugVC new];
    [self showRootController:vc inWindow:window];
    
#else
    ZZStartWireframe* wireframe = [ZZStartWireframe new];
    [wireframe presentStartControllerFromWindow:window completion:completionBlock];
    
#endif

    self.secretWireframe = [ZZSecretWireframe new];
    self.secretController = [ZZSecretScreenController startObserveWithType:ZZEnvelopObserveType
                                         touchType:ZZSecretScreenTouchTypeWithoutDelay
                                            window:window completionBlock:^{
            [self _presentSecretScreenFromNavigationController:(UINavigationController*)window.rootViewController];
    }];
}

- (void)showRootController:(UIViewController*)vc inWindow:(UIWindow *)window
{
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
    [self _executeCompletionBlock];
}

- (void)_presentSecretScreenFromNavigationController:(UINavigationController*)nc
{   
    [self.secretWireframe presentOrDismissSecretControllerFromNavigationController:nc];
}

- (void)_executeCompletionBlock
{
    if (self.completionBlock)
    {
        self.completionBlock();
    }
}

@end

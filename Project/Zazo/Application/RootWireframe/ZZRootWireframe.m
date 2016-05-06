//
//  ZZRootWireframe.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRootWireframe.h"
#import "ZZSecretWireframe.h"
#import "ZZStartWireframe.h"

NSString *const ZZNeedsToShowSecretScreenNotificationName = @"ZZNeedsToShowSecretScreenNotificationName";

@interface ZZRootWireframe ()

@property (nonatomic, strong) ZZSecretWireframe *secretWireframe;
@property (nonatomic, copy) ANCodeBlock completionBlock;
@property (nonatomic, weak) UIWindow *window;

@end

@implementation ZZRootWireframe

- (void)showStartViewControllerInWindow:(UIWindow *)window completionBlock:(ANCodeBlock)completionBlock
{
    window.backgroundColor = [UIColor whiteColor];
    self.completionBlock = completionBlock;

#ifdef DEBUG_CONTROLLER
    UIViewController* vc = [ANDebugVC new];
    [self showRootController:vc inWindow:window];
#else
    ZZStartWireframe *wireframe = [ZZStartWireframe new];
    [wireframe presentStartControllerFromWindow:window completion:completionBlock];
#endif

    self.window = window;

    self.secretWireframe = [ZZSecretWireframe new];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_needsToShowSecretScreenNotification)
                                                 name:ZZNeedsToShowSecretScreenNotificationName
                                               object:nil];

}

- (void)_needsToShowSecretScreenNotification
{
    [self _presentSecretScreenFromNavigationController:(UINavigationController *)self.window.rootViewController];
}

- (void)showRootController:(UIViewController *)vc inWindow:(UIWindow *)window
{
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nc;
    [self _executeCompletionBlock];
}

- (void)_presentSecretScreenFromNavigationController:(UINavigationController *)nc
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

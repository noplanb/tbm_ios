//
//  ZZAuthWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZMainWireframe;

@interface ZZAuthWireframe : NSObject

@property (nonatomic, strong) ZZMainWireframe *mainWireframe;

- (void)presentAuthControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)presentAuthControllerFromNavigationController:(UINavigationController *)nc;
- (void)dismissAuthController;
- (void)presentGridController;
- (void)presentNetworkTestController;
- (void)showSecretScreen;

@end

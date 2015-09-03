//
//  ZZAuthWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAuthWireframe : NSObject

- (void)presentAuthControllerFromWindow:(UIWindow*)window;
- (void)presentAuthControllerFromNavigationController:(UINavigationController*)nc;
- (void)dismissAuthController;
- (void)presentGridModule;

@end

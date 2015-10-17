//
//  ZZMenuWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZMenuWireframe : NSObject

- (void)presentMenuControllerFromWindow:(UIWindow *)window;
- (void)toggleMenu;
- (void)closeMenu;

- (void)attachAdditionalPanGestureToMenu:(UIPanGestureRecognizer*)pan;

@end

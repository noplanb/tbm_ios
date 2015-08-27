//
//  ZZGridWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import "ZZMenuWireframe.h"

@class ZZGridPresenter;

@interface ZZGridWireframe : NSObject

@property (nonatomic, strong) ZZGridPresenter* presenter;
@property (nonatomic, strong) ZZMenuWireframe* menuWireFrame;

- (void)presentGridControllerFromNavigationController:(UINavigationController*)nc;
- (void)dismissGridController;
- (void)toggleMenu;
- (void)closeMenu;

- (void)presentEditFriendsWireframe;

@end

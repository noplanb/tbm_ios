//
//  ZZMenuWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuModuleDelegate.h"

@class ZZMainWireframe, ZZMenuPresenter;

@interface ZZMenuWireframe : NSObject

@property (nonatomic, strong, readonly) UIViewController* menuController;
@property (nonatomic, strong, readonly) ZZMenuPresenter* presenter;
@property (nonatomic, strong) ZZMainWireframe* mainWireframe;

@end

//
//  ZZGridVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridViewInterface.h"
#import "ZZGridModuleInterface.h"
#import "ZZBaseVC.h"
#import "ZZTabbarView.h"

@interface ZZGridVC : ZZBaseVC <ZZGridViewInterface, ZZTabbarViewItem>

@property (nonatomic, weak) id <ZZGridModuleInterface> eventHandler;

@end

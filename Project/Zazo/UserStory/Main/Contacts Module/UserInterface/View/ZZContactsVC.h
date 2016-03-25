//
//  ZZContactsVC.h
//  zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsViewInterface.h"
#import "ZZContactsModuleInterface.h"
#import "ZZBaseVC.h"
#import "ZZTabbarView.h"

@interface ZZContactsVC : ZZBaseVC <ZZContactsViewInterface, ZZTabbarViewItem>

@property (nonatomic, weak) id<ZZContactsModuleInterface> eventHandler;

@end

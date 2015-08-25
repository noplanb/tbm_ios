//
//  ZZMenuVC.h
//  zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuViewInterface.h"
#import "ZZMenuModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZMenuVC : ZZBaseVC <ZZMenuViewInterface>

@property (nonatomic, weak) id<ZZMenuModuleInterface> eventHandler;

@end

//
//  ZZGridVC.h
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridViewInterface.h"
#import "ZZGridModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZGridVC : ZZBaseVC <ZZGridViewInterface>

@property (nonatomic, weak) id<ZZGridModuleInterface> eventHandler;

@end

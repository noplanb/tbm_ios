//
//  ZZAuthVC.h
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthViewInterface.h"
#import "ZZAuthModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZAuthVC : ZZBaseVC <ZZAuthViewInterface>

@property (nonatomic, weak) id <ZZAuthModuleInterface> eventHandler;

@end

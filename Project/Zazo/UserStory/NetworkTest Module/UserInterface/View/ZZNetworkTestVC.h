//
//  ZZNetworkTestVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestViewInterface.h"
#import "ZZNetworkTestModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZNetworkTestVC : ZZBaseVC <ZZNetworkTestViewInterface>

@property (nonatomic, weak) id <ZZNetworkTestModuleInterface> eventHandler;

@end

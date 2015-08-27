//
//  ZZDebugStateVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateViewInterface.h"
#import "ZZDebugStateModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZDebugStateVC : ZZBaseVC <ZZDebugStateViewInterface>

@property (nonatomic, weak) id<ZZDebugStateModuleInterface> eventHandler;

@end

//
//  ZZStartVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartViewInterface.h"
#import "ZZStartModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZStartVC : ZZBaseVC <ZZStartViewInterface>

@property (nonatomic, weak) id<ZZStartModuleInterface> eventHandler;

@end

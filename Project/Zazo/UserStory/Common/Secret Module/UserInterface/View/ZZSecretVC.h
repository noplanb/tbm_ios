//
//  ZZSecretVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretViewInterface.h"
#import "ZZSecretModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZSecretVC : ZZBaseVC <ZZSecretViewInterface>

@property (nonatomic, weak) id <ZZSecretModuleInterface> eventHandler;

@end

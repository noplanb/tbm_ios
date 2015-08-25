//
//  ZZSecretScreenVC.h
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenViewInterface.h"
#import "ZZSecretScreenModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZSecretScreenVC : ZZBaseVC <ZZSecretScreenViewInterface>

@property (nonatomic, weak) id<ZZSecretScreenModuleInterface> eventHandler;

@end

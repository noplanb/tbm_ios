//
//  ZZAppDependecesInjection.m
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAppDependecesInjection.h"
#import <Typhoon.h>
#import "ZZSettingsAssembly.h"

@implementation ZZAppDependecesInjection

- (void)configureTyphoon
{
    TyphoonComponentFactory* factory = [[TyphoonBlockComponentFactory alloc] initWithAssemblies:@[[ZZSettingsAssembly assembly]]];
    [factory makeDefault];
}

@end

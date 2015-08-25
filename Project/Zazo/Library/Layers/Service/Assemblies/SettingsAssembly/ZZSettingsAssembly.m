//
//  ZZSettingsAssembly.m
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSettingsAssembly.h"
#import "NSObject+ANUserDefaults.h"
#import "ANStoredSettingsManager.h"




@interface ZZSettingsAssembly ()

@property (nonatomic, strong) ZZSettingsModel* settingsModel;

@end

@implementation ZZSettingsAssembly


- (ZZSettingsModel*)currentSettings
{
    return [TyphoonDefinition withClass:[ZZSettingsModel class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(serverUrl) with:[[ANStoredSettingsManager shared] serverUrl]];
        [definition injectProperty:@selector(serverIndex) with:@([[ANStoredSettingsManager shared] serverIndex])];
        [definition injectProperty:@selector(isDebugEnabled) with:[[ANStoredSettingsManager shared] isDebugEnabled]];
    }];
}

@end

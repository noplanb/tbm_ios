//
//  ZZSettingsAssembly.m
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSettingsAssembly.h"
#import "ZZStoredSettingsManager.h"

@interface ZZSettingsAssembly () //TODO: think on settings model injection for unit test purposes

@property (nonatomic, strong) ZZSettingsModel* settingsModel;

@end

@implementation ZZSettingsAssembly

- (ZZSettingsModel*)currentSettings
{
    return [TyphoonDefinition withClass:[ZZSettingsModel class] configuration:^(TyphoonDefinition *definition) {
//        [definition injectProperty:@selector(serverUrl) with:[[ZZStoredSettingsManager shared] serverURLString]];
//        [definition injectProperty:@selector(serverIndex) with:@([[ZZStoredSettingsManager shared] serverEndpointState])];
//        [definition injectProperty:@selector(isDebugEnabled) with:[[ZZStoredSettingsManager shared] isDebugModeEnabled]];/TODO:
    }];
}

@end

//
//  ZZSettingsAssembly.h
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "TyphoonAssembly.h"
#import "ZZSettingsModel.h"

static NSString* const ZZCurrentSettingsModel = @"currentSettings";

@interface ZZSettingsAssembly : TyphoonAssembly

- (ZZSettingsModel*)currentSettings;

@end

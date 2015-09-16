//
//  ZZGridActionStoredSettings.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"

@interface ZZGridActionStoredSettings : NSObject

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature;

+ (instancetype)shared;

@end

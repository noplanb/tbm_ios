//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TBMConfig.h"

@interface TBMDebugData : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *mobileNumber;

@property(nonatomic, strong) NSString *version;

@property(nonatomic, assign) TBMConfigDebugMode debugMode;
@property(nonatomic, assign) TBMConfigServerState serverState;

@end
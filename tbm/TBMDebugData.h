//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBMServerState) {
    TBMServerStateProduction,
    TBMServerStateDeveloper,
    TBMServerStateCustom,
};

@interface TBMDebugData : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *mobileNumber;

@property(nonatomic, assign) BOOL debugMode;
@property(nonatomic, assign) TBMServerState serverState;

@end
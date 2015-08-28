//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TBMConfig.h"
#import "TBMDispatch.h"

@interface TBMDebugData : NSObject

/**
* Version
*/
@property(nonatomic, strong) NSString *version;

/**
* User data
*/
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *mobileNumber;

/**
* Config Debug mode
*/
@property(nonatomic, assign) TBMConfigDebugMode debugMode;

/**
* Server
*/
@property(nonatomic, assign) TBMConfigServerState serverState;
@property(nonatomic, copy) NSString *serverAddress;

/**
* DispatchType
*/
@property TBMDispatchType dispatchType;

@end
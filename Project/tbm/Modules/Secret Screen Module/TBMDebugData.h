//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import "ZZStoredSettingsManager.h"

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
@property(nonatomic, assign) BOOL debugMode;

/**
* Server
*/
@property(nonatomic, assign) ZZConfigServerState serverState;
@property(nonatomic, copy) NSString *serverAddress;

@end
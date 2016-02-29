//
//  ZZSettingsModel.h
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseDomainModel.h"

extern const struct ZZDebugSettingsStateDomainModelAttributes {
    __unsafe_unretained NSString *serverURLString;
    __unsafe_unretained NSString *serverIndex;
    __unsafe_unretained NSString *isDebugEnabled;
    __unsafe_unretained NSString *version;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *phoneNumber;
    __unsafe_unretained NSString *useRearCamera;
    __unsafe_unretained NSString *sendBrokenVideo;
    __unsafe_unretained NSString *enableAllFeatures;
} ZZDebugSettingsStateDomainModelAttributes;

@interface ZZDebugSettingsStateDomainModel : ANBaseDomainModel

@property (nonatomic, strong) NSString* serverURLString;
@property (nonatomic, assign) NSInteger serverIndex;
@property (nonatomic, assign) BOOL isDebugEnabled;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, assign) BOOL useRollbarSDK;
@property (nonatomic, assign) BOOL sendIncorrectFilesize;

@end

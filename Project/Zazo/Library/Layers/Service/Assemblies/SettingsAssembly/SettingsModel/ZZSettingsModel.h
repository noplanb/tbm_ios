//
//  ZZSettingsModel.h
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZSettingsModel : NSObject

@property (nonatomic, strong) NSString* serverUrl;
@property (nonatomic, strong) NSNumber* serverIndex;
@property (nonatomic, assign) BOOL isDebugEnabled;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* phoneNumber;

@end

//
//  ZZSettingsModel.h
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZSettingsModel : NSObject

@property (nonatomic, strong) NSString* serverURLString;
@property (nonatomic, assign) NSInteger serverIndex;
@property (nonatomic, assign) BOOL isDebugEnabled;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, assign) BOOL useRearCamera;
@property (nonatomic, assign) BOOL sendBrokenVideo;
@property (nonatomic, assign) BOOL forceRegSMS;
@property (nonatomic, assign) BOOL forceRegCall;
@property (nonatomic, assign) BOOL enableAllFeatures;

@end

//
//  ANSystemSettingsManager.h
//  Zazo
//
//  Created by ANODA on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ZZStoredSettingsManager : NSObject

typedef NS_ENUM(NSUInteger, ZZConfigServerState) {
    ZZConfigServerStateProduction = 0,
    ZZConfigServerStateDeveloper = 1,
    ZZConfigServerStateCustom = 2,
};


#pragma mark - Configutation

@property (nonatomic, assign) BOOL debugModeEnabled;
@property (nonatomic, assign) BOOL shouldUseRollBarSDK;

@property (nonatomic, strong) NSString* serverURLString;
@property (nonatomic, assign) ZZConfigServerState serverEndpointState;
@property (nonatomic, assign) BOOL isPushNotificatonEnabled;


#pragma mark - Messages

@property (nonatomic, assign) BOOL messageEverRecorded;
@property (nonatomic, assign) BOOL messageEverPlayed;


#pragma mark - User

@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* authToken;
@property (nonatomic, copy) NSString* mobileNumber;

@property (nonatomic, assign) BOOL wasPermissionAccess;

+ (instancetype)shared;

@end

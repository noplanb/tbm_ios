//
//  ANSystemSettingsManager.m
//  Zazo
//
//  Created by ANODA on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

static NSString* const kZZServerEndpointStateKey = @"kTBMConfigServerStateKey";
static NSString* const kZZServerURLStringKey = @"kTBMConfigCustomServerURLKey";
static NSString* const kZZDebugModeEnabledKey = @"kTBMConfigDeviceDebugModeKey";

static NSString* const kZZShouldUseServerLoggingEnabledKey = @"kZZShouldUseServerLoggingEnabledKey";

static NSString* const kZZUserAuthToken = @"kZZUserAuthToken";
static NSString* const kZZUserItemID = @"kZZUserItemID";
static NSString* const kZZUserMobileNumber = @"kZZUserMobileNumber";

static NSString* const kZZServerIsPushNotificationEnabled = @"kIsPushNotificationEnabled";

#import "ZZStoredSettingsManager.h"
#import "NSObject+ANUserDefaults.h"

@implementation ZZStoredSettingsManager

@dynamic serverURLString;
@dynamic serverEndpointState;
@dynamic debugModeEnabled;

@dynamic userID;
@dynamic authToken;
@dynamic mobileNumber;

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

- (void)cleanSettings
{
    self.debugModeEnabled = NO;
    self.serverEndpointState = ZZConfigServerStateProduction;
    self.serverURLString = nil;

    self.userID = nil;
    self.authToken = nil;
    self.mobileNumber = nil;
}


#pragma mark - Configuration

//debug mode
- (void)setDebugModeEnabled:(BOOL)debugModeEnabled
{
    [NSObject an_updateBool:debugModeEnabled forKey:kZZDebugModeEnabledKey];
}

- (BOOL)debugModeEnabled
{
    return [NSObject an_boolForKey:kZZDebugModeEnabledKey];
}

- (void)setShouldUseRollBarSDK:(BOOL)shouldUseRollBarSDK
{
    [NSObject an_updateBool:shouldUseRollBarSDK forKey:kZZShouldUseServerLoggingEnabledKey];
}

- (BOOL)shouldUseRollBarSDK
{
    return [NSObject an_boolForKey:kZZShouldUseServerLoggingEnabledKey];
}

//serverURL
- (void)setServerURLString:(NSString *)serverURLString
{
    [NSObject an_updateObject:serverURLString forKey:kZZServerURLStringKey];
}

- (NSString *)serverURLString
{
    return [NSObject an_stringForKey:kZZServerURLStringKey];
}

//server endpoint
- (void)setServerEndpointState:(ZZConfigServerState)serverEndpointState
{
    [NSObject an_updateInteger:serverEndpointState forKey:kZZServerEndpointStateKey];
}

- (ZZConfigServerState)serverEndpointState
{
    return [NSObject an_integerForKey:kZZServerEndpointStateKey];
}

// push notification
- (void)setIsPushNotificationEnabled:(BOOL)isPushNotificationEnabled
{
    [NSObject an_updateBool:isPushNotificationEnabled forKey:kZZServerIsPushNotificationEnabled];
}

- (BOOL)isPushNotificationEnabled
{
    return [NSObject an_boolForKey:kZZServerIsPushNotificationEnabled];
}

#pragma mark - User

- (void)setUserID:(NSString *)userID
{
    [NSObject an_updateObject:userID forKey:kZZUserItemID];
}

- (NSString *)userID
{
    return [NSObject an_objectForKey:kZZUserItemID];
}

- (void)setAuthToken:(NSString*)authToken
{
    [NSObject an_updateObject:authToken forKey:kZZUserAuthToken];
}

- (NSString*)authToken
{
    return [NSObject an_objectForKey:kZZUserAuthToken];
}

- (NSString *)mobileNumber
{
    return [NSObject an_objectForKey:kZZUserMobileNumber];
}

- (void)setMobileNumber:(NSString *)mobileNumber
{
    [NSObject an_updateObject:mobileNumber forKey:kZZUserMobileNumber];
}

@end

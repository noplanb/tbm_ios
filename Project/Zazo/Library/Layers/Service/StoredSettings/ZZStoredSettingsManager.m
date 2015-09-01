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
static NSString* const kZZForceSMSEnabledKey = @"kZZForceSMSEnabledKey";
static NSString* const kZZForceCallEnabledKey = @"kZZForceCallEnabledKey";
static NSString* const kZZShouldUseRollBarSDKEnabledKey = @"kZZShouldUseRollBarSDKEnabledKey";

static NSString* const kZZHintsDidStartPlayKey = @"kMessagePlayedNSUDkey";
static NSString* const kZZHintsDidStartRecordKey = @"kMessageRecordedNSUDkey";

//TODO:
//@"kAbortRecordUsageHintNSUDkey"
//@"kDeleteFriendUsageUsageHintNSUDkey"
//@"kEarpieceUsageUsageHintNSUDkey"
//@"kFrontCameraUsageUsageHintNSUDkey"
//@"kInviteHintNSUDkey"
//@"kInviteSomeoneElseNSUDkey"
//@"kPlayHintNSUDkey"
//@"kRecordHintNSUDkey"
//@"kRecordWelcomeHintNSUDkey"
//@"kSentHintNSUDkey"
//@"kSpinUsageUsageUsageHintNSUDkey"
//@"kViewedHintNSUDkey"
//@"kWelcomeHintNSUDkey"
//
//maksimbazarov [12:50 AM]
//@"kLastUnlockedFeatureNSUDKey"

#import "ZZStoredSettingsManager.h"
#import "NSObject+ANUserDefaults.h"

@implementation ZZStoredSettingsManager

@dynamic serverURLString;
@dynamic serverEndpointState;
@dynamic debugModeEnabled;

@dynamic hintsDidStartRecord;
@dynamic hintsDidStartPlay;

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
    
    self.hintsDidStartPlay = NO;
    self.hintsDidStartRecord = NO;
}


#pragma mark - Configuration

//force SMS
- (void)setForceSMS:(BOOL)forceSMS
{
    [self an_updateBool:forceSMS forKey:kZZForceSMSEnabledKey];
}

- (BOOL)forceSMS
{
    return [self an_boolForKey:kZZForceSMSEnabledKey];
}

//force Call
- (void)setForceCall:(BOOL)forceCall
{
    [self an_updateBool:forceCall forKey:kZZForceCallEnabledKey];
}

- (BOOL)forceCall
{
    return [self an_boolForKey:kZZForceCallEnabledKey];
}

//debug mode
- (void)setDebugModeEnabled:(BOOL)debugModeEnabled
{
    [self an_updateBool:debugModeEnabled forKey:kZZDebugModeEnabledKey];
}

- (BOOL)debugModeEnabled
{
    return [self an_boolForKey:kZZDebugModeEnabledKey];
}

- (void)setShouldUseRollBarSDK:(BOOL)shouldUseRollBarSDK
{
    [self an_updateBool:shouldUseRollBarSDK forKey:kZZShouldUseRollBarSDKEnabledKey];
}

- (BOOL)shouldUseRollBarSDK
{
    return [self an_boolForKey:kZZShouldUseRollBarSDKEnabledKey];
}

//serverURL
- (void)setServerURLString:(NSString *)serverURLString
{
    [self an_updateObject:serverURLString forKey:kZZServerURLStringKey];
}

- (NSString*)serverURLString
{
    return [self an_stringForKey:kZZServerURLStringKey];
}

//server endpoint
- (void)setServerEndpointState:(ZZConfigServerState)serverEndpointState
{
    [self an_updateInteger:serverEndpointState forKey:kZZServerEndpointStateKey];
}

- (ZZConfigServerState)serverEndpointState
{
    return [self an_integerForKey:kZZServerEndpointStateKey];
}


#pragma mark - Hints

//hints did start view
- (void)setHintsDidStartPlay:(BOOL)hintsDidStartPlay
{   //convension, legacy support
    [self an_updateObject:@(hintsDidStartPlay) forKey:kZZHintsDidStartPlayKey];
}

- (BOOL)hintsDidStartPlay
{
    return [[self an_objectForKey:kZZHintsDidStartPlayKey] boolValue];
}

//hints did start record
- (void)setHintsDidStartRecord:(BOOL)hintsDidStartRecord
{   //convension, legacy support
    [self an_updateObject:@(hintsDidStartRecord) forKey:kZZHintsDidStartRecordKey];
}

- (BOOL)hintsDidStartRecord
{
    return [[self an_objectForKey:kZZHintsDidStartRecordKey] boolValue];
}


@end

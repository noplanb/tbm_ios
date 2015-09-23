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

static NSString* const kZZUserAuthToken = @"kZZUserAuthToken";
static NSString* const kZZUserItemID = @"kZZUserItemID";

static NSString* const kZZHintsDidStartPlayKey = @"kMessagePlayedNSUDkey";
static NSString* const kZZHintsDidStartRecordKey = @"kMessageRecordedNSUDkey";
static NSString *const kAbortRecordUsageHintDidShowKey = @"kAbortRecordUsageHintDidShowKey";
static NSString *const kDeleteFriendUsageUsageHintDidShowKey = @"kDeleteFriendUsageUsageHintDidShowKey";
static NSString *const kEarpieceUsageUsageHintDidShowKey = @"kEarpieceUsageUsageHintDidShowKey";
static NSString *const kFrontCameraUsageUsageHintDidShowKey = @"kFrontCameraUsageUsageHintDidShowKey";
static NSString *const kInviteHintDidShowKey = @"kInviteHintDidShowKey";
static NSString *const kInviteSomeoneElseKey = @"kInviteSomeoneElseKey";
static NSString *const kPlayHintDidShowKey = @"kPlayHintDidShowKey";
static NSString *const kRecordHintDidShowKey = @"kRecordHintDidShowKey";
static NSString *const kRecordWelcomeHintDidShowKey = @"kRecordWelcomeHintDidShowKey";
static NSString *const kSentHintDidShowKey = @"kSentHintDidShowKey";
static NSString *const kSpinUsageUsageUsageHintDidShowKey = @"kSpinUsageUsageUsageHintDidShowKey";
static NSString *const kViewedHintDidShowKey = @"kViewedHintDidShowKey";
static NSString *const kWelcomeHintDidShowKey = @"kWelcomeHintDidShowKey";

static NSString *const kLastUnlockedFeatureKey = @"kLastUnlockedFeatureKey";

#import "ZZStoredSettingsManager.h"
#import "NSObject+ANUserDefaults.h"

@implementation ZZStoredSettingsManager

@dynamic serverURLString;
@dynamic serverEndpointState;
@dynamic debugModeEnabled;

@dynamic userID;
@dynamic authToken;

@dynamic hintsDidStartRecord;
@dynamic hintsDidStartPlay;
@dynamic deleteFriendHintWasShown;
@dynamic earpieceHintWasShown;
@dynamic frontCameraHintWasShown;
@dynamic inviteHintWasShown;
@dynamic inviteSomeoneHintWasShown;
@dynamic playHintWasShown;
@dynamic recordHintWasShown;
@dynamic recordWelcomeHintWasShown;
@dynamic sentHintWasShown;
@dynamic spinHintWasShown;
@dynamic viewedHintWasShown;
@dynamic welcomeHintWasShown;

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

    self.userID = nil;
    self.authToken = nil;
}


#pragma mark - Configuration

//force SMS
- (void)setForceSMS:(BOOL)forceSMS
{
    [NSObject an_updateBool:forceSMS forKey:kZZForceSMSEnabledKey];
}

- (BOOL)forceSMS
{
    return [NSObject an_boolForKey:kZZForceSMSEnabledKey];
}

//force Call
- (void)setForceCall:(BOOL)forceCall
{
    [NSObject an_updateBool:forceCall forKey:kZZForceCallEnabledKey];
}

- (BOOL)forceCall
{
    return [NSObject an_boolForKey:kZZForceCallEnabledKey];
}

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
    [NSObject an_updateBool:shouldUseRollBarSDK forKey:kZZShouldUseRollBarSDKEnabledKey];
}

- (BOOL)shouldUseRollBarSDK
{
    return [NSObject an_boolForKey:kZZShouldUseRollBarSDKEnabledKey];
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


#pragma mark - Hints

//hints did start view
- (void)setHintsDidStartPlay:(BOOL)hintsDidStartPlay
{   //convension, legacy support
    [NSObject an_updateObject:@(hintsDidStartPlay) forKey:kZZHintsDidStartPlayKey];
}

- (BOOL)hintsDidStartPlay
{
    return [[NSObject an_objectForKey:kZZHintsDidStartPlayKey] boolValue];
}

//hints did start record
- (void)setHintsDidStartRecord:(BOOL)hintsDidStartRecord
{   //convension, legacy support
    [NSObject an_updateObject:@(hintsDidStartRecord) forKey:kZZHintsDidStartRecordKey];
}

- (BOOL)hintsDidStartRecord
{
    return [[NSObject an_objectForKey:kZZHintsDidStartRecordKey] boolValue];
}

- (BOOL)abortRecordHintWasShown
{
    return [[NSObject an_objectForKey:kRecordHintDidShowKey] boolValue];
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

- (void)setAbortRecordHintWasShown:(BOOL)abortRecordHintWasShown
{
    [NSObject an_updateBool:abortRecordHintWasShown forKey:kAbortRecordUsageHintDidShowKey];
}

- (BOOL)deleteFriendHintWasShown
{
    return [[NSObject an_objectForKey:kDeleteFriendUsageUsageHintDidShowKey] boolValue];
}

- (void)setDeleteFriendHintWasShown:(BOOL)deleteFriendHintWasShown
{
    [NSObject an_updateBool:deleteFriendHintWasShown forKey:kDeleteFriendUsageUsageHintDidShowKey];

}

- (BOOL)earpieceHintWasShown
{
    return [[NSObject an_objectForKey:kEarpieceUsageUsageHintDidShowKey] boolValue];
}

- (void)setEarpieceHintWasShown:(BOOL)earpieceHintWasShown
{
    [NSObject an_updateBool:earpieceHintWasShown forKey:kEarpieceUsageUsageHintDidShowKey];

}

- (BOOL)frontCameraHintWasShown
{
    return [[NSObject an_objectForKey:kFrontCameraUsageUsageHintDidShowKey] boolValue];
}

- (void)setFrontCameraHintWasShown:(BOOL)frontCameraHintWasShown
{
    [NSObject an_updateBool:frontCameraHintWasShown forKey:kFrontCameraUsageUsageHintDidShowKey];
}

- (BOOL)inviteHintWasShown
{
    return [[NSObject an_objectForKey:kInviteHintDidShowKey] boolValue];
}

- (void)setInviteHintWasShown:(BOOL)inviteHintWasShown
{
    [NSObject an_updateBool:inviteHintWasShown forKey:kInviteHintDidShowKey];
}

- (BOOL)inviteSomeoneHintWasShown
{
    return [[NSObject an_objectForKey:kInviteSomeoneElseKey] boolValue];
}

- (void)setInviteSomeoneHintWasShown:(BOOL)inviteSomeoneHintWasShown
{
    [NSObject an_updateBool:inviteSomeoneHintWasShown forKey:kInviteSomeoneElseKey];
}

- (BOOL)playHintWasShown
{
    return [[NSObject an_objectForKey:kPlayHintDidShowKey] boolValue];
}

- (void)setPlayHintWasShown:(BOOL)playHintWasShown
{
    [NSObject an_updateBool:playHintWasShown forKey:kPlayHintDidShowKey];
}

- (BOOL)recordHintWasShown
{
    return [[NSObject an_objectForKey:kRecordHintDidShowKey] boolValue];
}

- (void)setRecordHintWasShown:(BOOL)recordHintWasShown
{
    [NSObject an_updateBool:recordHintWasShown forKey:kRecordHintDidShowKey];
}

- (BOOL)recordWelcomeHintWasShown
{
    return [[NSObject an_objectForKey:kRecordWelcomeHintDidShowKey] boolValue];
}

- (void)setRecordWelcomeHintWasShown:(BOOL)recordWelcomeHintWasShown
{
    [NSObject an_updateBool:recordWelcomeHintWasShown forKey:kRecordWelcomeHintDidShowKey];
}

- (BOOL)sentHintWasShown
{
    return [[NSObject an_objectForKey:kSentHintDidShowKey] boolValue];
}

- (void)setSentHintWasShown:(BOOL)sentHintWasShown
{
    [NSObject an_updateBool:sentHintWasShown forKey:kSentHintDidShowKey];
}

- (BOOL)spinUsageUsageUsageHintDidShow
{
    return [[NSObject an_objectForKey:kSpinUsageUsageUsageHintDidShowKey] boolValue];
}

- (void)setSpinUsageUsageUsageHintDidShow:(BOOL)spinUsageUsageUsageHintDidShow
{
    [NSObject an_updateBool:spinUsageUsageUsageHintDidShow forKey:kSpinUsageUsageUsageHintDidShowKey];
}

- (BOOL)viewedHintDidShow
{
    return [[NSObject an_objectForKey:kViewedHintDidShowKey] boolValue];
}

- (void)setViewedHintDidShow:(BOOL)viewedHintDidShow
{
    [NSObject an_updateBool:viewedHintDidShow forKey:kViewedHintDidShowKey];
}

- (BOOL)welcomeHintWasShown
{
    return [[NSObject an_objectForKey:kWelcomeHintDidShowKey] boolValue];
}

- (void)setWelcomeHintWasShown:(BOOL)welcomeHintWasShown
{
    [NSObject an_updateBool:welcomeHintWasShown forKey:kWelcomeHintDidShowKey];
}

- (NSUInteger)lastUnlockedFeature
{
    NSInteger value = [[NSObject an_objectForKey:kLastUnlockedFeatureKey] integerValue];
    NSUInteger result = value > 0 ? value : 0;
    return result;
}

- (void)setLastUnlockedFeature:(NSUInteger)lastUnlockedFeature
{
    [NSObject an_updateInteger:lastUnlockedFeature forKey:kLastUnlockedFeatureKey];
}

@end

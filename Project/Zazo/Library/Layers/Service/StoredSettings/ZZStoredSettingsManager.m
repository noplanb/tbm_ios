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

@dynamic hintsDidStartRecord;
@dynamic hintsDidStartPlay;
@dynamic deleteFriendUsageUsageHintDidShow;
@dynamic earpieceUsageUsageHintDidShow;
@dynamic frontCameraUsageUsageHintDidShow;
@dynamic inviteHintDidShow;
@dynamic inviteSomeoneElseKey;
@dynamic playHintDidShow;
@dynamic recordHintDidShow;
@dynamic recordWelcomeHintDidShow;
@dynamic sentHintDidShow;
@dynamic spinUsageUsageUsageHintDidShow;
@dynamic viewedHintDidShow;
@dynamic welcomeHintDidShow;

@dynamic userID;
@dynamic authToken;

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

- (NSString *)serverURLString
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

- (BOOL)abortRecordUsageHintDidShow
{
    return [[self an_objectForKey:kRecordHintDidShowKey] boolValue];
}

#pragma mark - User

- (void)setUserID:(NSString *)userID
{
    [self an_updateObject:userID forKey:kZZUserItemID];
}

- (NSString *)userID
{
    return [self an_objectForKey:kZZUserItemID];
}

- (void)setAuthToken:(NSString*)authToken
{
    [self an_updateObject:authToken forKey:kZZUserAuthToken];
}

- (NSString*)authToken
{
    return [self an_objectForKey:kZZUserAuthToken];
}

- (void)setAbortRecordUsageHintDidShow:(BOOL)abortRecordUsageHintDidShow
{
    [self an_updateBool:abortRecordUsageHintDidShow forKey:kAbortRecordUsageHintDidShowKey];
}

- (BOOL)deleteFriendUsageUsageHintDidShow
{
    return [[self an_objectForKey:kDeleteFriendUsageUsageHintDidShowKey] boolValue];
}

- (void)setDeleteFriendUsageUsageHintDidShow:(BOOL)deleteFriendUsageUsageHintDidShow
{
    [self an_updateBool:deleteFriendUsageUsageHintDidShow forKey:kDeleteFriendUsageUsageHintDidShowKey];

}

- (BOOL)earpieceUsageUsageHintDidShow
{
    return [[self an_objectForKey:kEarpieceUsageUsageHintDidShowKey] boolValue];
}

- (void)setEarpieceUsageUsageHintDidShow:(BOOL)earpieceUsageUsageHintDidShow
{
    [self an_updateBool:earpieceUsageUsageHintDidShow forKey:kEarpieceUsageUsageHintDidShowKey];

}

- (BOOL)frontCameraUsageUsageHintDidShow
{
    return [[self an_objectForKey:kFrontCameraUsageUsageHintDidShowKey] boolValue];
}

- (void)setFrontCameraUsageUsageHintDidShow:(BOOL)frontCameraUsageUsageHintDidShow
{
    [self an_updateBool:frontCameraUsageUsageHintDidShow forKey:kFrontCameraUsageUsageHintDidShowKey];
}

- (BOOL)inviteHintDidShow
{
    return [[self an_objectForKey:kInviteHintDidShowKey] boolValue];
}

- (void)setInviteHintDidShow:(BOOL)inviteHintDidShow
{
    [self an_updateBool:inviteHintDidShow forKey:kInviteHintDidShowKey];
}

- (BOOL)inviteSomeoneElseKey
{
    return [[self an_objectForKey:kInviteSomeoneElseKey] boolValue];
}

- (void)setInviteSomeoneElseKey:(BOOL)inviteSomeoneElseKey
{
    [self an_updateBool:inviteSomeoneElseKey forKey:kInviteSomeoneElseKey];
}

- (BOOL)playHintDidShow
{
    return [[self an_objectForKey:kPlayHintDidShowKey] boolValue];
}

- (void)setPlayHintDidShow:(BOOL)playHintDidShow
{
    [self an_updateBool:playHintDidShow forKey:kPlayHintDidShowKey];
}

- (BOOL)recordHintDidShow
{
    return [[self an_objectForKey:kRecordHintDidShowKey] boolValue];
}

- (void)setRecordHintDidShow:(BOOL)recordHintDidShow
{
    [self an_updateBool:recordHintDidShow forKey:kRecordHintDidShowKey];
}

- (BOOL)recordWelcomeHintDidShow
{
    return [[self an_objectForKey:kRecordWelcomeHintDidShowKey] boolValue];
}

- (void)setRecordWelcomeHintDidShow:(BOOL)recordWelcomeHintDidShow
{
    [self an_updateBool:recordWelcomeHintDidShow forKey:kRecordWelcomeHintDidShowKey];
}

- (BOOL)sentHintDidShow
{
    return [[self an_objectForKey:kSentHintDidShowKey] boolValue];
}

- (void)setSentHintDidShow:(BOOL)sentHintDidShow
{
    [self an_updateBool:sentHintDidShow forKey:kSentHintDidShowKey];
}

- (BOOL)spinUsageUsageUsageHintDidShow
{
    return [[self an_objectForKey:kSpinUsageUsageUsageHintDidShowKey] boolValue];
}

- (void)setSpinUsageUsageUsageHintDidShow:(BOOL)spinUsageUsageUsageHintDidShow
{
    [self an_updateBool:spinUsageUsageUsageHintDidShow forKey:kSpinUsageUsageUsageHintDidShowKey];
}

- (BOOL)viewedHintDidShow
{
    return [[self an_objectForKey:kViewedHintDidShowKey] boolValue];
}

- (void)setViewedHintDidShow:(BOOL)viewedHintDidShow
{
    [self an_updateBool:viewedHintDidShow forKey:kViewedHintDidShowKey];
}

- (BOOL)welcomeHintDidShow
{
    return [[self an_objectForKey:kWelcomeHintDidShowKey] boolValue];
}

- (void)setWelcomeHintDidShow:(BOOL)welcomeHintDidShow
{
    [self an_updateBool:welcomeHintDidShow forKey:kWelcomeHintDidShowKey];
}

- (NSUInteger)lastUnlockedFeature
{
    NSInteger value = [[self an_objectForKey:kLastUnlockedFeatureKey] integerValue];
    NSUInteger result = value > 0 ? value : 0;
    return result;
}

- (void)setLastUnlockedFeature:(NSUInteger)lastUnlockedFeature
{
    [self an_updateInteger:lastUnlockedFeature forKey:kLastUnlockedFeatureKey];
}


@end

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

static NSString* const kZZHintsDidStartPlayKey = @"kMessagePlayedNSUDkey";
static NSString* const kZZHintsDidStartRecordKey = @"kMessageRecordedNSUDkey";

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

//serverURL
- (void)setServerURLString:(NSString *)serverURLString
{
    [self an_updateObject:serverURLString forKey:kZZServerURLStringKey];
}

- (NSString*)serverURLString
{
    return [self an_stringForKey:kZZServerURLStringKey];
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


#pragma mark - Loading

- (NSString*)serverURLStringTest
{
    NSString* serverSrting;
    NSArray* serverURLs = @[@"http://prod.zazoapp.com", @"http://staging.zazoapp.com"]; // move to enum
    serverSrting = self.serverEndpointState < ZZConfigServerStateCustom ?
                   serverURLs[self.serverEndpointState] : self.serverURLString;
    
    return serverSrting;
}


@end

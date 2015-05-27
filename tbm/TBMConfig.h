//
//  TBMConfig.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *CONFIG_APP_NAME = @"Zazo";

// Make sure these 4 are set correctly before a release.

//static BOOL CONFIG_DEBUG_MODE = YES;
typedef NS_ENUM(NSUInteger, TBMConfigDebugMode) {
    TBMConfigDebugModeOff   = 0,
    TBMConfigDebugModeOn    = 1,
};
static NSString *kTBMConfigDebugModeKey = @"kTBMConfigDebugModeKey"; //User defaults key for debug mode

static NSString *CONFIG_VERSION_NUMBER = @"27";
static NSString *CONFIG_VERSION_STRING = @"2.2.1";

/** * * *
* Device debug mode states
*/
typedef NS_ENUM(NSUInteger, TBMConfigDeviceDebugMode) {
    TBMConfigDeviceDebugModeOff = 0,
    TBMConfigDeviceDebugModeProd    = 1,
};
static NSString *kTBMConfigDeviceDebugModeKey = @"kTBMConfigDeviceDebugModeKey"; //User defaults key for debug mode

/** * * *
* Server configuration
*/
typedef NS_ENUM(NSUInteger, TBMConfigServerState) {
    TBMServerStateProduction = 0,
    TBMServerStateDeveloper = 1,
    TBMServerStateCustom = 2,
};

static NSString *kTBMConfigServerStateKey = @"kTBMConfigServerStateKey"; //User defaults key for server (default is 0)
static NSString *kTBMServers[3] = {@"http://prod.zazoapp.com", @"http://staging.zazoapp.com", @"http://192.168.1.82:3000"};

/**
* Other values
*/
static NSString *CONFIG_INVITE_BASE_URL_STRING = @"zazoapp.com/l/";
static NSString *CONFIG_APP_STORE_URL = @"https://itunes.apple.com/us/app/zazo/id922294638";
static NSString *CONFIG_DING_SOUND = @"BeepSin30.wav";

@interface TBMConfig : NSObject

/**
* Returns server state
*/
+ (TBMConfigServerState)serverState;

/**
* Returns server state
*/
+ (NSString *)serverURL;

/**
* Change current server
*/
+ (void)changeServerTo:(TBMConfigServerState)state;


/**
* Returns current device debugmode
*/
+ (TBMConfigDeviceDebugMode)deviceDebugMode;

/**
* Change current device debugmode
*/
+ (void)changeDeviceDebugModeTo:(TBMConfigDeviceDebugMode)mode;


+ (NSURL *)videosDirectoryUrl;

+ (NSURL *)resourceUrl;

+ (NSURL *)thumbMissingUrl;

+ (NSURL *)tbmBaseUrl;

+ (NSString *)appName;

+ (NSString *)tbmBasePath;

+ (NSString *)deviceDebugModeString;

+ (UIColor *)registrationBackGroundColor;


+ (TBMConfigDebugMode)configDebugMode;

+ (void)changeConfigDebugModeTo:(TBMConfigDebugMode)mode;
@end

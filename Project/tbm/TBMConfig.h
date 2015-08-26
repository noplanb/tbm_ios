/**
*
* Application global configuration class
*
* Created by Sani Elfishawy on 4/29/14.
* Edited by Maksim Bazarov on 5/28/14
* Copyright (c) 2014 No Plan B. All rights reserved.
*/

/**
* Application name
*/

static NSString *CONFIG_APP_NAME = @"Zazo"; // from info.plist

/** * * *
* Server configuration
*/
//moved
//typedef NS_ENUM(NSUInteger, TBMConfigServerState) {
//    TBMServerStateProduction = 0,
//    TBMServerStateDeveloper = 1,
//    TBMServerStateCustom = 2,
//};
//moved
//static NSString *kTBMConfigServerStateKey = @"kTBMConfigServerStateKey"; //User defaults key for server (default is 0)
//static NSString *kTBMConfigCustomServerURLKey = @"kTBMConfigCustomServerURLKey"; //User defaults key for custom server url
//static NSString *kTBMServers[3] = {@"http://prod.zazoapp.com", @"http://staging.zazoapp.com"};

/**
* Config Debug Mode
*/
//typedef NS_ENUM(NSUInteger, TBMConfigDebugMode) {
//    TBMConfigDebugModeOff   = 0,
//    TBMConfigDebugModeOn    = 1,
//};
//static NSString *kTBMConfigDebugModeKey = @"kTBMConfigDebugModeKey"; //User defaults key for debug mode

// from info.plist
static NSString *CONFIG_VERSION_NUMBER = @"36";
static NSString *CONFIG_VERSION_STRING = @"2.3.1";

/** * * *
* Device debug mode
*/
//typedef NS_ENUM(NSUInteger, TBMConfigDeviceDebugMode) {
//    TBMConfigDeviceDebugModeOff = 0,
//    TBMConfigDeviceDebugModeProd    = 1,
//};
//static NSString *kTBMConfigDeviceDebugModeKey = @"kTBMConfigDeviceDebugModeKey"; //User defaults key for debug mode


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
//+ (TBMConfigServerState)serverState;

//+ (NSString *)serverURL;

/**
* Change custom server url
*/
//+ (void)changeCustomServerURL:(NSString *)url;

/**
* Change current server state
*/
//+ (void)changeServerTo:(TBMConfigServerState)state;

/**
* Returns current device debug mode
*/
//+ (TBMConfigDeviceDebugMode)deviceDebugMode;

/**
* Change current device debug mode
*/
//+ (void)changeDeviceDebugModeTo:(TBMConfigDeviceDebugMode)mode;

///**
//* Returns config debug mode
//*/
//+ (TBMConfigDebugMode)configDebugMode;
///**
//* Change config debug mode
//*/
//+ (void)changeConfigDebugModeTo:(TBMConfigDebugMode)mode;

/**
* Legacy
*/
+ (NSURL *)videosDirectoryUrl;

+ (NSURL *)resourceUrl;

+ (NSURL *)thumbMissingUrl;

+ (NSURL *)tbmBaseUrl;

+ (NSString *)appName;

+ (NSString *)tbmBasePath;

+ (NSString *)deviceBuildString;

+ (UIColor *)registrationBackGroundColor;


@end

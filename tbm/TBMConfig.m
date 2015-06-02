//
//  TBMConfig.m
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#define UD [NSUserDefaults standardUserDefaults]

#import <OBLogger/OBLoggerCore.h>
#import "TBMConfig.h"

@implementation TBMConfig

#pragma mark - Server configuration

+ (TBMConfigServerState)serverState {
    NSInteger serverState = [UD integerForKey:kTBMConfigServerStateKey];
    if (serverState >= 0 && serverState <= 3) {
        return (TBMConfigServerState) serverState;
    }
    else {
        return TBMServerStateProduction;
    }
}

+ (NSString *)serverURL {

    TBMConfigServerState serverState = [self serverState];
    NSString *serverURL;

    if (serverState == TBMServerStateCustom) {
        serverURL = [UD stringForKey:kTBMConfigCustomServerURLKey];
    }

    if (serverState == TBMServerStateDeveloper) {
        serverURL = kTBMServers[TBMServerStateDeveloper];
    }

    if (!serverURL) {
        serverURL = kTBMServers[TBMServerStateProduction];
    }

    return serverURL;
}

+ (void)changeCustomServerURL:(NSString *)url {
    if (url) {
        [UD setObject:url forKey:kTBMConfigCustomServerURLKey];
        [UD synchronize];
    }
}

+ (void)changeServerTo:(TBMConfigServerState)state {
    [UD setInteger:state forKey:kTBMConfigServerStateKey];
    [UD synchronize];
}

#pragma mark - Device debug mode

//TODO: Maksim. Please make debug mode a boolean it is either YES for debug mode or NO for not debug mode. This is overkill!
+ (TBMConfigDeviceDebugMode)deviceDebugMode {
    NSInteger debugMode = [UD integerForKey:kTBMConfigDeviceDebugModeKey];

    if (debugMode >= 0 && debugMode <= 1) {
        return (TBMConfigDeviceDebugMode) debugMode;
    }
    else {
        return TBMConfigDeviceDebugModeOff;
    }
}

+ (NSString *)deviceDebugModeString {
    if ([self deviceDebugMode] == TBMConfigDeviceDebugModeProd) {
        return @"prod";
    }
    return @"dev";
}

+ (void)changeDeviceDebugModeTo:(TBMConfigDeviceDebugMode)mode {
    [UD setInteger:mode forKey:kTBMConfigDeviceDebugModeKey];
    [UD synchronize];
}

#pragma mark - Config debug mode

+ (TBMConfigDebugMode)configDebugMode {
    NSInteger debugMode = [UD integerForKey:kTBMConfigDebugModeKey];

    if (debugMode > 0) {
        return TBMConfigDebugModeOn;
    }
    else {
        return TBMConfigDebugModeOff;
    }
}

+ (void)changeConfigDebugModeTo:(TBMConfigDebugMode)mode {
    [UD setInteger:mode forKey:kTBMConfigDebugModeKey];
    [UD synchronize];
}

#pragma mark - Appearance configuration

+ (UIColor *)registrationBackGroundColor {
    return [UIColor colorWithRed:0.61f green:0.75f blue:0.27f alpha:1.0f];
}

#pragma mark - Legacy

+ (NSString *)appName {
    return CONFIG_APP_NAME;
}

+ (NSURL *)videosDirectoryUrl {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)resourceUrl {
    return [[NSBundle mainBundle] resourceURL];
}

+ (NSURL *)tbmBaseUrl {
    return [NSURL URLWithString:[self serverURL]];
}

+ (NSURL *)thumbMissingUrl {
    return [[[TBMConfig resourceUrl] URLByAppendingPathComponent:@"head"] URLByAppendingPathExtension:@"png"];
}

+ (NSString *)tbmBasePath {
    return [self serverURL];
}


@end

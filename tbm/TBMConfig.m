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

+ (TBMConfigServerState)serverState {
    NSInteger serverState = [UD integerForKey:kTBMConfigServerStateKey];
    if (serverState >= 0 && serverState <= 3) {
        OB_INFO(@"CONFIG # returned serverState: %u",serverState);
        return (TBMConfigServerState) serverState;
    }
    else {
        OB_INFO(@"CONFIG # returned serverState: %u",TBMServerStateProduction);
        return TBMServerStateProduction;
    }
}

+ (NSString *)serverURL {
    NSString *serverURL = kTBMServers[[self serverState]];
    if (!serverURL) {
        return kTBMServers[TBMServerStateProduction];
    }
    OB_INFO(@"CONFIG # returned serverURL: %@",serverURL);
    return serverURL;
}

+ (void)changeServerTo:(TBMConfigServerState)state {
    [UD setInteger:state forKey:kTBMConfigServerStateKey];
    [UD synchronize];
    OB_INFO(@"CONFIG # changeServerTo: %u",state);
}

+ (TBMConfigDeviceDebugMode)deviceDebugMode {
    NSInteger debugMode = [UD integerForKey:kTBMConfigDeviceDebugModeKey];

    if (debugMode >= 0 && debugMode <= 1) {
        OB_INFO(@"CONFIG # returned deviceDebugMode: %u",debugMode);
        return (TBMConfigDeviceDebugMode) debugMode;
    }
    else {
        OB_INFO(@"CONFIG # returned deviceDebugMode: %u", TBMConfigDeviceDebugModeOff);
        return TBMConfigDeviceDebugModeOff;
    }
}

+ (void)changeDeviceDebugModeTo:(TBMConfigDeviceDebugMode)mode {
    [UD setInteger:mode forKey:kTBMConfigDeviceDebugModeKey];
    [UD synchronize];
    OB_INFO(@"CONFIG # changed deviceDebugMode to : %u", TBMConfigDeviceDebugModeOff);
}


+ (NSString *)appName {
    return CONFIG_APP_NAME;
}


+ (NSURL *)videosDirectoryUrl {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)thumbMissingUrl {
    return [[[TBMConfig resourceUrl] URLByAppendingPathComponent:@"head"] URLByAppendingPathExtension:@"png"];
}

+ (NSURL *)resourceUrl {
    return [[NSBundle mainBundle] resourceURL];
}

+ (NSURL *)tbmBaseUrl {
    return [NSURL URLWithString:[self serverURL]];
}

+ (NSString *)tbmBasePath {
    return [self serverURL];
}

+ (NSString *)deviceDebugModeString {
    if( [self deviceDebugMode] == TBMConfigDeviceDebugModeProd) {
        return @"prod";
    }
    return @"dev";
}

+ (UIColor *)registrationBackGroundColor {
    return [UIColor colorWithRed:0.61f green:0.75f blue:0.27f alpha:1.0f];
}


+ (TBMConfigDebugMode)configDebugMode {
    NSInteger debugMode = [UD integerForKey:kTBMConfigDebugModeKey];

    if (debugMode > 0) {
        OB_INFO(@"CONFIG # returned configebugMode: ON");
        return TBMConfigDebugModeOn;
    }
    else {
        OB_INFO(@"CONFIG # returned configebugMode: OFF");
        return TBMConfigDebugModeOff;
    }
}

+ (void)changeConfigDebugModeTo:(TBMConfigDebugMode)mode {
    [UD setInteger:mode forKey:kTBMConfigDebugModeKey];
    [UD synchronize];
    OB_INFO(@"CONFIG # changed configebugMode to : %u", mode);
}

@end

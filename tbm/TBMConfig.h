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
static BOOL CONFIG_DEBUG_MODE = NO;
static NSString *CONFIG_VERSION_NUMBER = @"23";
static NSString *CONFIG_VERSION_STRING = @"2.0.8";

// This is necessary because fucking apple has a different apns gateway depending on whether the device is
// provisioned with a dev cert or production/adhoc cert
static NSString *CONFIG_DEVICE_BUILD = @"prod"; // prod / dev

//static NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://192.168.1.82:3000";
//static NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://prod.zazoapp.com";
static NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://staging.zazoapp.com";


static NSString *CONFIG_INVITE_BASE_URL_STRING = @"http://zazoapp.com/l/";


static NSString *CONFIG_DING_SOUND = @"BeepSin30.wav";


@interface TBMConfig : NSObject
+ (NSURL *)videosDirectoryUrl;
+ (NSURL *)resourceUrl;
+ (NSURL *)thumbMissingUrl;
+ (NSURL *)tbmBaseUrl;
+ (NSString *)appName;
+ (NSString *)tbmBasePath;
@end

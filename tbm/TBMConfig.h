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
static NSString *CONFIG_VERSION_NUMBER = @"18";
static NSString *CONFIG_VERSION_STRING = @"1.426";

// This is necessary because fucking apple has a different apns gateway depending on whether the device is
// provisioned with a dev cert or production/adhoc cert
static NSString *CONFIG_DEVICE_BUILD = @"dev"; // prod / dev

//static const NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://www.threebyme.com";
//static const NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://staging-tbm.elasticbeanstalk.com";
static const NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://zazo-dev1-4.elasticbeanstalk.com";
//static const NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://zazo-dev1-5.elasticbeanstalk.com";
//static NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://192.168.1.82:3000";


@interface TBMConfig : NSObject
+ (NSURL *)videosDirectoryUrl;
+ (NSURL *)resourceUrl;
+ (NSURL *)thumbMissingUrl;
+ (NSURL *)tbmBaseUrl;
+ (NSString *)appName;
+ (NSString *)tbmBasePath;
@end

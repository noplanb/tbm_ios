//
//  TBMConfig.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *CONFIG_VERSION_NUMBER = @"8";

static NSString *CONFIG_VERSION_STRING = @"1.34";
static NSString *CONFIG_APP_NAME = @"Three By Me";

static const NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://www.threebyme.com";
//static NSString *CONFIG_SERVER_BASE_URL_STRING = @"http://192.168.1.82:3000";

@interface TBMConfig : NSObject
+ (NSURL *)videosDirectoryUrl;
+ (NSURL *)resourceUrl;
+ (NSURL *)thumbMissingUrl;
+ (NSURL *)tbmBaseUrl;
+ (NSString *)appName;
+ (NSString *)tbmBasePath;
@end

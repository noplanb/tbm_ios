//
//  TBMConfig.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMConfig : NSObject

+ (NSURL *)videosDirectoryUrl;
+ (NSURL *)resourceUrl;
+ (NSURL *)thumbMissingUrl;
+ (NSURL *)tbmBaseUrl;

@end

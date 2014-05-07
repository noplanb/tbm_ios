//
//  TBMConfig.m
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMConfig.h"

static NSString * const TBMBaseUrlString = @"http://www.threebyme.com";

@implementation TBMConfig

+ (NSURL *)videosDirectoryUrl{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)thumbMissingUrl{
    return [[[TBMConfig resourceUrl] URLByAppendingPathComponent:@"head"] URLByAppendingPathExtension:@"png"];
}

+ (NSURL *)resourceUrl{
    return [[NSBundle mainBundle] resourceURL];
}

+ (NSURL *)tbmBaseUrl{
    return [NSURL URLWithString:TBMBaseUrlString];
}

@end

//
//  TBMHttpClient.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHttpClient.h"

static NSString * const TBMBaseUrlString = @"http://www.threebyme.com";

@implementation TBMHttpClient

+ (instancetype)sharedClient {
    static TBMHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TBMHttpClient alloc] initWithBaseURL:[NSURL URLWithString:TBMBaseUrlString]];
    });
    return _sharedClient;
}

@end

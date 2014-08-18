//
//  TBMHttpClient.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHttpClient.h"
#import "TBMConfig.h"
@implementation TBMHttpClient

+ (instancetype)sharedClient {
    static TBMHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TBMHttpClient alloc] initWithBaseURL:[TBMConfig tbmBaseUrl]];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    return _sharedClient;
}

@end

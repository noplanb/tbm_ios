//
//  ZZVideoNetworkTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoNetworkTransportService.h"
#import "ZZVideoNetworkTransport.h"

@implementation ZZVideoNetworkTransportService

+ (RACSignal *)deleteVideoFileWithName:(NSString *)filename
{
    NSParameterAssert(filename);

    NSDictionary *parameters = @{@"filename" : [NSObject an_safeString:filename]};
    return [ZZVideoNetworkTransport deleteVideoWithParameters:parameters];
}

@end

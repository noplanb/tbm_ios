//
//  ZZVideoNetworkTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoNetworkTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZVideoNetworkTransport

+ (RACSignal *)deleteVideoWithParameters:(NSDictionary *)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiDeleteVideo httpMethod:ANHttpMethodTypeGET];
}

@end

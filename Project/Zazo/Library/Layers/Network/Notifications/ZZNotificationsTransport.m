//
//  ZZNotificationsTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNotificationsTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZNotificationsTransport


#pragma mark - General

+ (RACSignal*)uploadTokenWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiSavePushToken parameters:parameters httpMethod:ANHttpMethodTypePOST];
}


#pragma mark - Outgoing Events

+ (RACSignal*)sendVideoReceivedNotificationWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiNotificationVideoReceived
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypePOST];
}

+ (RACSignal*)sendVideoStatusUpdateNotificationWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiNotificationVideoStatusUpdate
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypePOST];
}

@end

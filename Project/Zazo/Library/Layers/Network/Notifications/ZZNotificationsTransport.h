//
//  ZZNotificationsTransport.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZNotificationsTransport : NSObject


#pragma mark - General

+ (RACSignal*)uploadTokenWithParameters:(NSDictionary*)parameters;


#pragma mark - Outgoing Events

+ (RACSignal*)sendVideoReceivedNotificationWithParameters:(NSDictionary*)parameters;
+ (RACSignal*)sendVideoStatusUpdateNotificationWithParameters:(NSDictionary*)parameters;

@end

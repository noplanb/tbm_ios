//
//  ZZNotificationTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNotificationTransportService.h"
#import "ZZNotificationsTransport.h"
#import "NSObject+ANSafeValues.h"
#import "ZZFriendDomainModel.h"
#import "ZZUserDomainModel.h"

static const struct
{
    __unsafe_unretained NSString *buildNumber;
    __unsafe_unretained NSString *apnsToken;
    __unsafe_unretained NSString *platform;
    __unsafe_unretained NSString *mKey;
    __unsafe_unretained NSString *itemID;
    __unsafe_unretained NSString *isUserHasApp;
    
    __unsafe_unretained NSString *targetMKey;
    __unsafe_unretained NSString *fromMKey;
    __unsafe_unretained NSString *senderName;
    __unsafe_unretained NSString *videoItemID;
    __unsafe_unretained NSString *toUserMKey;
    __unsafe_unretained NSString *status;
    __unsafe_unretained NSString *type;
    
    __unsafe_unretained NSString *videoReceived;
    __unsafe_unretained NSString *videoStatusUpdate;
    
} ZZNotificationsServerParameters =
{
    .buildNumber = @"device_build",
    .apnsToken = @"push_token",
    .platform = @"device_platform",
    .mKey = @"mkey",
    .targetMKey = @"target_mkey",
    .fromMKey = @"from_mkey",
    .videoItemID = @"video_id",
    .senderName = @"sender_name",
    
    .toUserMKey = @"to_mkey",
    
    
    .status = @"status",
    .type = @"type",
    
    .videoReceived = @"video_received",
    .videoStatusUpdate = @"video_status_update",
};

@implementation ZZNotificationTransportService


#pragma mark - General APNS

+ (RACSignal*)uploadToken:(NSString*)token userMKey:(NSString*)mkey buildString:(NSString*)buildString
{
    NSDictionary* parameters = @{ZZNotificationsServerParameters.mKey           : [NSObject an_safeString:mkey],
                                 ZZNotificationsServerParameters.buildNumber    : [NSObject an_safeString:buildString],
                                 ZZNotificationsServerParameters.apnsToken      : [NSObject an_safeString:token],
                                 ZZNotificationsServerParameters.platform       : @"ios"};
    
    return [ZZNotificationsTransport uploadTokenWithParameters:parameters];
}


#pragma mark - Outgoing Events

+ (RACSignal*)sendVideoReceivedNotificationTo:(ZZFriendDomainModel*)model videoItemID:(NSString*)videoItemID from:(ZZUserDomainModel*)user
{
    NSDictionary* parameters = @{ZZNotificationsServerParameters.targetMKey     : [NSObject an_safeString:model.mKey],
                                 ZZNotificationsServerParameters.fromMKey       : [NSObject an_safeString:user.mkey],
                                 ZZNotificationsServerParameters.senderName     : [NSObject an_safeString:user.firstName],
                                 ZZNotificationsServerParameters.videoItemID    : [NSObject an_safeString:videoItemID]};
    
    return [ZZNotificationsTransport sendVideoReceivedNotificationWithParameters:parameters];
}

+ (RACSignal*)sendVideoStatusUpdateNotificationTo:(ZZFriendDomainModel*)model
                                      videoItemID:(NSString*)videoItemID
                                           status:(NSString*)status
                                             from:(ZZUserDomainModel*)user
{
    NSDictionary* parameters = @{ZZNotificationsServerParameters.targetMKey     : model.mKey,
                                 ZZNotificationsServerParameters.toUserMKey     : user.mkey,
                                 ZZNotificationsServerParameters.status         : status,
                                 ZZNotificationsServerParameters.videoItemID    : videoItemID};
    
    return [ZZNotificationsTransport sendVideoStatusUpdateNotificationWithParameters:parameters];
}

@end

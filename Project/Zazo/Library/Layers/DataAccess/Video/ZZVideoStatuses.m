//
//  ZZVideoStatuses.m
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

#pragma mark - Incoming Status

static NSString *incomeTypeString[] = {
    @"INCOMING_VIDEO_STATUS_NEW",
    @"INCOMING_VIDEO_STATUS_DOWNLOADING",
    @"INCOMING_VIDEO_STATUS_DOWNLOADED",
    @"INCOMING_VIDEO_STATUS_VIEWED",
    @"INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY"
};

static NSString *incomeTypeShortString[] = {
    @"New",
    @"Downloading",
    @"Downloaded",
    @"Viewed",
    @"Failed permanently"
};

NSString* ZZVideoIncomingStatusShortStringFromEnumValue(ZZVideoIncomingStatus type)
{
    return incomeTypeShortString[type];
}

NSString* ZZVideoIncomingStatusStringFromEnumValue(ZZVideoIncomingStatus type)
{
    return incomeTypeString[type];
}

ZZVideoIncomingStatus ZZVideoIncomingStatusEnumValueFromString(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:incomeTypeString count:5];
    return [array indexOfObject:string];
}


#pragma mark - Outgoing status

static NSString *outgoingTypeString[] = {
    @"OUTGOING_VIDEO_STATUS_NONE",
    @"OUTGOING_VIDEO_STATUS_NEW",
    @"OUTGOING_VIDEO_STATUS_QUEUED",
    @"OUTGOING_VIDEO_STATUS_UPLOADING",
    @"OUTGOING_VIDEO_STATUS_UPLOADED",
    @"OUTGOING_VIDEO_STATUS_DOWNLOADED",
    @"OUTGOING_VIDEO_STATUS_VIEWED",
    @"OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY"
};

NSString* ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatus type)
{
    return outgoingTypeString[type];
}

ZZVideoOutgoingStatus ZZVideoOutgoingStatusEnumValueFromString(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:outgoingTypeString count:8];
    return [array indexOfObject:string];
}


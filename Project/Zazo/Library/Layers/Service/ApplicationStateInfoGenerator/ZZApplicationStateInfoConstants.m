//
//  ZZApplicationStateInfoConstants.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationStateInfoConstants.h"

#pragma mark - Outgoing

static NSString *outgoingTypesString[] = {
    @"NONE",
    @"NEW",
    @"QUEUED"
    @"UPLOADING",
    @"UPLOADED",
    @"DOWNLOADED",
    @"VIEWED",
    @"FAILED"
};

NSString* ZZOutgoingVideoInfoStringFromEnumValue(ZZVideoOutgoingStatus type)
{
    return outgoingTypesString[type];
}

ZZVideoOutgoingStatus ZZOutgoingVideoInfoEnumValueFromSrting(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:outgoingTypesString count:8];
    return [array indexOfObject:[NSObject an_safeString:string]];
}


#pragma mark - Incoming

static NSString *incomingTypesString[] = {
    @"NEW",
    @"DOWNLOADING"
    @"DOWNLOADED",
    @"VIEWED",
    @"PERMANENTLY"
};

NSString* ZZIncomingVideoInfoStringFromEnumValue(ZZVideoIncomingStatus type)
{
    return incomingTypesString[type];
}

ZZVideoIncomingStatus ZZIncomingVideoInfoEnumValueFromSrting(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:incomingTypesString count:5];
    return [array indexOfObject:[NSObject an_safeString:string]];
}


#pragma mark - Server

static NSString *serverTypesString[] = {
    @"Production",
    @"Development"
    @"Custom",
};

NSString* ZZServerFormattedStringFromEnumValue(ZZConfigServerState type)
{
    return serverTypesString[type];
}


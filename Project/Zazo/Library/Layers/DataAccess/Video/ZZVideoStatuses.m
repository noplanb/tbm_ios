//
//  ZZVideoStatuses.m
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"
#import "TBMFriend.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendDataProvider.h"


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
    int count = sizeof(outgoingTypeString) / sizeof(outgoingTypeString[0]);
    NSArray* array = [NSArray arrayWithObjects:outgoingTypeString count:count];
    return [array indexOfObject:string];
}

NSString* ZZVideoStatusStringWithFriend(TBMFriend* friend)
{
    if (friend.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeOutgoing)
    {
        return ZZVideoOutgoingStatusWithFriend(friend);
    }
    else
    {
        return ZZVideoIncomingStatusStringWithFriend(friend);
    }
}

TBMVideo* ZZNewestIncomingVideoFromFriend(TBMFriend* friend)
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:TBMVideoAttributes.videoId ascending:YES];
    NSArray* videos = [friend.videos sortedArrayUsingDescriptors:@[d]];
    return [videos lastObject];
}

NSString* ZZVideoIncomingStatusStringWithFriend(TBMFriend* friend)
{
    TBMVideo* video = ZZNewestIncomingVideoFromFriend(friend);
     ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    
    if (ANIsEmpty(video))
    {
        return [friendModel displayName];
    }
    
    if (video.statusValue == ZZVideoIncomingStatusDownloading)
    {
        if (video.downloadRetryCountValue == 0)
        {
            return @"Downloading...";
        }
        else
        {
            return [NSString stringWithFormat:@"Dwnld r%@", video.downloadRetryCount];
        }
    }
    else if (video.statusValue == ZZVideoIncomingStatusFailedPermanently)
    {
        return @"Downloading e!";
    }
    else
    {
        return [friendModel displayName];
    }
}

NSString* ZZVideoOutgoingStatusWithFriend(TBMFriend* friend)
{
    NSString *statusString;
    switch (friend.outgoingVideoStatusValue)
    {
        case ZZVideoOutgoingStatusNew:
            statusString = @"q...";
            break;
        case ZZVideoOutgoingStatusUploading:
            if (friend.uploadRetryCountValue == 0)
            {
                statusString = @"p...";
            }
            else
            {
                statusString = [NSString stringWithFormat:@"r%ld...", (long) [friend.uploadRetryCount integerValue]];
            }
            break;
        case ZZVideoOutgoingStatusUploaded:
            statusString = @".s..";
            break;
        case ZZVideoOutgoingStatusDownloaded:
            statusString = @"..p.";
            break;
        case ZZVideoOutgoingStatusViewed:
            statusString = @"v!";
            break;
        case ZZVideoOutgoingStatusFailedPermanently:
            statusString = @"e!";
            break;
        default:
            statusString = nil;
    }
    
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    
    NSString *fn = (statusString == nil || friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusViewed) ? [friendModel displayName] : [friendModel shortFirstName];
    
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}


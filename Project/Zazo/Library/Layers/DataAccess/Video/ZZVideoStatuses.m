//
//  ZZVideoStatuses.m
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider+Entities.h"

NSString* ZZVideoOutgoingStatusWithFriend(ZZFriendDomainModel* friendModel);
NSString* ZZVideoIncomingStatusStringWithFriend(ZZFriendDomainModel*friendModel);

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

NSString* ZZVideoStatusStringWithFriendModel(ZZFriendDomainModel* friendModel)
{
    if (friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing)
    {
        return ZZVideoOutgoingStatusWithFriend(friendModel);
    }
    else
    {
        return ZZVideoIncomingStatusStringWithFriend(friendModel);
    }
}

ZZVideoDomainModel* ZZNewestIncomingVideoFromFriend(ZZFriendDomainModel* friendModel)
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:ZZVideoDomainModelAttributes.videoID ascending:YES];
    NSArray* videos = [friendModel.videos sortedArrayUsingDescriptors:@[d]];
    return [videos lastObject];
}

NSString* ZZVideoIncomingStatusStringWithFriend(ZZFriendDomainModel*friendModel)
{
    ZZVideoDomainModel *videoModel = ZZNewestIncomingVideoFromFriend(friendModel);

    if (ANIsEmpty(videoModel))
    {
        return [friendModel displayName];
    }
    
    if (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloading)
    {
        if (videoModel.downloadRetryCount == 0)
        {
            return @"Downloading...";
        }
        else
        {
            return [NSString stringWithFormat:@"Dwnld r%ld", (long)videoModel.downloadRetryCount];
        }
    }
    else if (videoModel.incomingStatusValue == ZZVideoIncomingStatusFailedPermanently)
    {
        return @"Downloading e!";
    }
    else
    {
        return [friendModel displayName];
    }
}

NSString* ZZVideoOutgoingStatusWithFriend(ZZFriendDomainModel* friendModel)
{
    NSString *statusString;
    switch (friendModel.lastOutgoingVideoStatus)
    {
        case ZZVideoOutgoingStatusNew:
            statusString = @"q...";
            break;
        case ZZVideoOutgoingStatusUploading:
            if (friendModel.uploadRetryCount == 0)
            {
                statusString = @"p...";
            }
            else
            {
                statusString = [NSString stringWithFormat:@"r%ld...", friendModel.uploadRetryCount];
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
    
    NSString *fn = (statusString == nil || friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusViewed) ? [friendModel displayName] : [friendModel shortFirstName];
    
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}
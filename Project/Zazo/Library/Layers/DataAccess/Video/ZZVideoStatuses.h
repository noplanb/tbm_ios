//
//  ZZVideoStatuses.h
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//
@class TBMFriend;
@class TBMVideo;
@class ZZFriendDomainModel;

typedef NS_ENUM (NSInteger, ZZVideoIncomingStatus)
{
    ZZVideoIncomingStatusNew,
    ZZVideoIncomingStatusDownloading,
    ZZVideoIncomingStatusDownloaded,
    ZZVideoIncomingStatusViewed,
    ZZVideoIncomingStatusFailedPermanently,
    ZZVideoIncomingStatusGhost,
};

typedef NS_ENUM (NSInteger, ZZVideoOutgoingStatus)
{
    ZZVideoOutgoingStatusNone,
    ZZVideoOutgoingStatusNew,
    ZZVideoOutgoingStatusQueued,
    ZZVideoOutgoingStatusUploading,
    ZZVideoOutgoingStatusUploaded,
    ZZVideoOutgoingStatusDownloaded,
    ZZVideoOutgoingStatusViewed,
    ZZVideoOutgoingStatusFailedPermanently,
    ZZVideoOutgoingStatusUnknown,
};

typedef NS_ENUM(NSInteger, ZZVideoStatusEventType)
{
    ZZVideoStatusEventTypeIncoming,
    ZZVideoStatusEventTypeOutgoing
};

typedef NS_ENUM(NSUInteger, ZZIncomingEventType) {
    ZZIncomingEventTypeVideo,
    ZZIncomingEventTypeMessage
};

NSString *ZZVideoIncomingStatusShortStringFromEnumValue(ZZVideoIncomingStatus);
NSString *ZZVideoIncomingStatusStringFromEnumValue(ZZVideoIncomingStatus);
NSString *ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatus);
NSString *ZZVideoStatusStringWithFriendModel(ZZFriendDomainModel *friend);

static NSString *const kDeleteFileNotification = @"fileDeletedNotification";
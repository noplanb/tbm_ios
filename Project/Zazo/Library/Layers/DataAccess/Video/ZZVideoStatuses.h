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

typedef NS_ENUM (NSInteger, ZZVideoIncomingStatus) {
    ZZVideoIncomingStatusNew,
    ZZVideoIncomingStatusDownloading,
    ZZVideoIncomingStatusDownloaded,
    ZZVideoIncomingStatusViewed,
    ZZVideoIncomingStatusFailedPermanently,
};

typedef NS_ENUM (NSInteger, ZZVideoOutgoingStatus) {
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

typedef NS_ENUM(NSInteger, ZZVideoStatusEventType) {
    ZZVideoStatusEventTypeIncoming,
    ZZVideoStatusEventTypeOutgoing
};

NSString* ZZVideoIncomingStatusShortStringFromEnumValue(ZZVideoIncomingStatus);
NSString* ZZVideoIncomingStatusStringFromEnumValue(ZZVideoIncomingStatus);
ZZVideoIncomingStatus ZZVideoIncomingStatusEnumValueFromString(NSString*);


NSString* ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatus);
ZZVideoOutgoingStatus ZZVideoOutgoingStatusEnumValueFromString(NSString*);

NSString* ZZVideoStatusStringWithFriend(TBMFriend* friend);
NSString* ZZVideoStatusStringWithFriendModel(ZZFriendDomainModel* friend);
TBMVideo* ZZNewestIncomingVideoFromFriend(TBMFriend* friend);
NSString* ZZVideoIncomingStatusStringWithFriend(TBMFriend* friend);
NSString* ZZVideoOutgoingStatusWithFriend(TBMFriend* friend);

static NSString* const kDeleteFileNotification = @"fileDeletedNotification";
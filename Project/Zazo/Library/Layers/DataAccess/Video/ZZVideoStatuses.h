//
//  ZZVideoStatuses.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM (NSInteger, ZZVideoIncomingStatus) {
    ZZVideoIncomingStatusNew,
    ZZVideoIncomingStatusDownloading,
    ZZVideoIncomingStatusDownloaded,
    ZZVideoIncomingStatusViewed,
    ZZVideoIncomingStatusFailedPermanently
};

typedef NS_ENUM (NSInteger, ZZVideoOutgoingStatus) {
    ZZVideoOutgoingStatusNone,
    ZZVideoOutgoingStatusNew,
    ZZVideoOutgoingStatusQueued,
    ZZVideoOutgoingStatusUploading,
    ZZVideoOutgoingStatusUploaded,
    ZZVideoOutgoingStatusDownloaded,
    ZZVideoOutgoingStatusViewed,
    ZZVideoOutgoingStatusFailedPermanently
};

typedef NS_ENUM(NSInteger, ZZVideoStatusEventType) {
    ZZVideoStatusEventTypeIncoming,
    ZZVideoStatusEventTypeOutgoing
};
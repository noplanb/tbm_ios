//
//  TBMFriend.h
//  tbm
//
//  Created by Sani Elfishawy on 8/18/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideo.h"
#import "_TBMFriend.h"
#import "ZZVideoStatuses.h"

@class TBMGridElement;

@interface TBMFriend : _TBMFriend
// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
//typedef NS_ENUM (NSInteger, TBMOutgoingVideoStatus) {
//    OUTGOING_VIDEO_STATUS_NONE,
//    OUTGOING_VIDEO_STATUS_NEW,
//    OUTGOING_VIDEO_STATUS_QUEUED,
//    OUTGOING_VIDEO_STATUS_UPLOADING,
//    OUTGOING_VIDEO_STATUS_UPLOADED,
//    OUTGOING_VIDEO_STATUS_DOWNLOADED,
//    OUTGOING_VIDEO_STATUS_VIEWED,
//    OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY,
//    OUTGOING_VIDEO_STATUS_UNKNOWN
//};


//typedef NS_ENUM(NSInteger, TBMVideoStatusEventType){
//    INCOMING_VIDEO_STATUS_EVENT_TYPE,
//    OUTGOING_VIDEO_STATUS_EVENT_TYPE
//};

// Finders
//+ (NSArray *)all;

//+ (NSUInteger)allUnviewedCount;notificationObject
//+ (NSUInteger)unviewedCountForGridCellAtIndex:(NSUInteger)index;
//+ (instancetype)findWithId:(NSString *)idTbm;
//+ (instancetype)findWithMkey:(NSString *)mkey;
//+ (instancetype)findWithMatchingPhoneNumber:(NSString *)phone;
//+ (NSUInteger)count;
//+ (NSUInteger)everSentNonInviteeFriendsCount;

// UI
//- (NSString *)displayName;

// Incoming videos
//- (BOOL) hasIncomingVideo;

//- (NSArray *) sortedIncomingVideos;

//- (TBMVideo *) oldestIncomingVideo;
//- (NSString *) oldestIncomingVideoId;
//- (TBMVideo *) newestIncomingVideo;
//- (BOOL) hasIncomingVideoId:(NSString *)videoId;

//- (BOOL) isNewestIncomingVideo:(TBMVideo *)video;

//- (BOOL) hasDownloadingVideo;
//- (BOOL) hasRetryingDownload;

//- (TBMVideo *) createIncomingVideoWithVideoId:(NSString *)videoId;

//- (TBMVideo *) firstPlayableVideo;
//- (TBMVideo *) firstUnviewedVideo;
//- (TBMVideo *) nextPlayableVideoAfterVideoId:(NSString *)videoId;

//- (TBMVideo *) nextUnviewedVideoAfterVideoId:(NSString *)videoId;

//- (NSInteger) unviewedCount;

//- (void) deleteAllViewedOrFailedVideos;


// VideoStatusNotification

//+ (void)addVideoStatusNotificationDelegate:(id)delegate;



//+ (void)fillAfterMigration;

//+ (NSArray *)everSentMkeys;

//+ (void)setEverSentForMkeys:(NSArray *)mkeys;

//- (NSString *)videoStatusString;
//- (NSString *)outgoingVideoStatusString;

//- (NSString *)fullName;

//- (NSString *)shortFirstName;

//- (BOOL)hasOutgoingVideo;

@end

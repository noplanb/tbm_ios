//
//  TBMFriend.h
//  tbm
//
//  Created by Sani Elfishawy on 8/18/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBMVideo.h"

#import "TBMDispatchProtocol.h"

@class TBMGridElement;

@protocol TBMVideoStatusNotificationProtocol <NSObject>
- (void)videoStatusDidChange:(TBMFriend *)friend;
@end

@interface TBMFriend : NSManagedObject <TBMDispatchProtocol>
// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
typedef NS_ENUM (NSInteger, TBMOutgoingVideoStatus) {
    OUTGOING_VIDEO_STATUS_NONE,
    OUTGOING_VIDEO_STATUS_NEW,
    OUTGOING_VIDEO_STATUS_QUEUED,
    OUTGOING_VIDEO_STATUS_UPLOADING,
    OUTGOING_VIDEO_STATUS_UPLOADED,
    OUTGOING_VIDEO_STATUS_DOWNLOADED,
    OUTGOING_VIDEO_STATUS_VIEWED,
    OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY
};


typedef NS_ENUM(NSInteger, TBMVideoStatusEventType){
    INCOMING_VIDEO_STATUS_EVENT_TYPE,
    OUTGOING_VIDEO_STATUS_EVENT_TYPE
};

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * idTbm;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mobileNumber;
@property (nonatomic, retain) NSString * outgoingVideoId;
@property (nonatomic) TBMOutgoingVideoStatus outgoingVideoStatus;
@property (nonatomic) TBMVideoStatusEventType lastVideoStatusEventType;
@property (nonatomic) TBMIncomingVideoStatus lastIncomingVideoStatus;
@property (nonatomic, retain) NSNumber * uploadRetryCount;
@property (nonatomic, retain) NSString * mkey;
@property (nonatomic, retain) NSString * ckey;
@property (nonatomic) BOOL hasApp;
@property (nonatomic, retain) NSSet *videos;
@property (nonatomic, retain) TBMGridElement *gridElement;
@property (nonatomic, retain) NSDate *timeOfLastAction;


// Finders
+ (NSArray *)all;
+ (NSUInteger)allUnviewedCount;
+ (instancetype)findWithId:(NSString *)idTbm;
+ (instancetype)findWithOutgoingVideoId:(NSString *)videoId;
+ (instancetype)findWithMkey:(NSString *)mkey;
+ (instancetype)findWithMatchingPhoneNumber:(NSString *)phone;
+ (NSUInteger)count;

// UI
- (NSString *)displayName;

// Incoming videos
- (void)printVideos;
- (BOOL) hasIncomingVideo;
- (NSArray *) sortedIncomingVideos;
- (TBMVideo *) oldestIncomingVideo;
- (NSString *) oldestIncomingVideoId;
- (TBMVideo *) newestIncomingVideo;
- (BOOL) hasIncomingVideoId:(NSString *)videoId;
- (BOOL) isNewestIncomingVideo:(TBMVideo *)video;
- (BOOL) hasDownloadingVideo;
- (BOOL) hasRetryingDownload;
- (TBMVideo *) createIncomingVideoWithVideoId:(NSString *)videoId;
- (TBMVideo *) firstPlayableVideo;
- (TBMVideo *) firstUnviewedVideo;
- (TBMVideo *) nextPlayableVideoAfterVideoId:(NSString *)videoId;
- (TBMVideo *) nextUnviewedVideoAfterVideoId:(NSString *)videoId;
- (NSInteger) unviewedCount;
- (void) deleteAllViewedOrFailedVideos;

// Create and destroy
+ (void)createWithId:(NSString *)idTbm complete:(void(^)(TBMFriend *friend))complete;
+ (void)createOrUpdateWithServerParams:(NSDictionary *)params complete:(void (^)(TBMFriend *friend))complete;
+ (NSUInteger)destroyAll;
+ (void)destroyWithId:(NSNumber *)idTbm;

// VideoStatusNotification
+ (void)addVideoStatusNotificationDelegate:(id)delegate;
+ (void)removeVideoStatusNotificationDelegate:(id)delegate;

- (UIImage *)thumbImage;

- (BOOL)isThumbNoPic;
- (void)generateThumbWithVideo:(TBMVideo *)video;

- (NSString *)videoStatusString;

- (NSString *)outgoingVideoStatusString;

// Probably should not expose this and rather have setters for various states.
- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)status video:(TBMVideo *)video;
- (void)setAndNotifyDownloadRetryCount:(NSNumber *)retryCount video:(TBMVideo *)video;

- (void)setViewedWithIncomingVideo:(TBMVideo *)video;
- (BOOL)incomingVideoNotViewed;

- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId;
- (void)handleOutgoingVideoCreatedWithVideoId:(NSString *)videoId;
- (void)handleOutgoingVideoUploadingWithVideoId:(NSString *)videoId;
- (void)handleOutgoingVideoUploadedWithVideoId:(NSString *)videoId;
- (void)handleOutgoingVideoViewedWithVideoId:(NSString *)videoId;
- (void)handleOutgoingVideoFailedPermanentlyWithVideoId:(NSString *)videoId;
- (void)handleUploadRetryCount:(NSNumber *)retryCount videoId:(NSString *)videoId;

- (NSString *)fullName;

- (BOOL)hasOutgoingVideo;

- (NSString *)OVStatusName;

@end

@interface TBMFriend (CoreDataGeneratedAccessors)

- (void)addVideosObject:(TBMVideo *)value;
- (void)removeVideosObject:(TBMVideo *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end

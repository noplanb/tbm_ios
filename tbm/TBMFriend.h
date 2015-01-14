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

@class TBMGridElement;

@protocol TBMVideoStatusNotificationProtocol <NSObject>
- (void)videoStatusDidChange:(TBMFriend *)friend;
@end

@interface TBMFriend : NSManagedObject
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
+ (instancetype)findWithId:(NSString *)idTbm;
+ (instancetype)findWithOutgoingVideoId:(NSString *)videoId;
+ (instancetype)findWithMkey:(NSString *)mkey;
+ (instancetype)findWithMatchingPhoneNumber:(NSString *)phone;
+ (NSUInteger)count;

// UI
- (NSString *)displayName;

// Incoming videos
- (void)printVideos;
- (NSArray *) sortedIncomingVideos;
- (TBMVideo *) oldestIncomingVideo;
- (NSString *) oldestIncomingVideoId;
- (TBMVideo *) newestIncomingVideo;
- (BOOL) hasIncomingVideoId:(NSString *)videoId;
- (BOOL) isNewestIncomingVideo:(TBMVideo *)video;
- (TBMVideo *) createIncomingVideoWithVideoId:(NSString *)videoId;
- (TBMVideo *) firstPlayableVideo;
- (TBMVideo *) nextPlayableVideoAfterVideoId:(NSString *)videoId;
- (NSInteger) unviewedCount;
- (void) deleteAllViewedOrFailedVideos;

// Create and destroy
+ (instancetype)createWithId:(NSNumber *)idTbm;
+ (instancetype)createWithServerParams:(NSDictionary *)params;
+ (NSUInteger)destroyAll;
+ (void)destroyWithId:(NSNumber *)idTbm;

// VideoStatusNotification
+ (void)addVideoStatusNotificationDelegate:(id)delegate;
+ (void)removeVideoStatusNotificationDelegate:(id)delegate;

- (NSURL *)thumbUrl;
- (BOOL)hasThumb;

- (NSString *)videoStatusString;
// Probably should not expose this and rather have setters for various states.
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId;
- (void)setAndNotifyUploadRetryCount:(NSNumber *)retryCount videoId:(NSString *)videoId;
- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)status video:(TBMVideo *)video;
- (void)setAndNotifyDownloadRetryCount:(NSNumber *)retryCount video:(TBMVideo *)video;

- (void)setViewedWithIncomingVideo:(TBMVideo *)video;
- (BOOL)incomingVideoNotViewed;

- (void)handleAfterOutgoingVideoCreated;
- (void)handleAfterOUtgoingVideoUploadStarted;
@end

@interface TBMFriend (CoreDataGeneratedAccessors)

- (void)addVideosObject:(TBMVideo *)value;
- (void)removeVideosObject:(TBMVideo *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end

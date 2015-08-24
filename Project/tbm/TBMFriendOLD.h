//
//  Friend.h
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBMVideo.h"

@protocol TBMVideoStatusNotoficationProtocol <NSObject>
- (void)videoStatusDidChange:(id)object;
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
@property (nonatomic, retain) NSString * outgoingVideoId;
@property (nonatomic) TBMOutgoingVideoStatus outgoingVideoStatus;
@property (nonatomic) TBMVideoStatusEventType lastVideoStatusEventType;
@property (nonatomic) TBMIncomingVideoStatus lastIncomingVideoStatus;
@property (nonatomic, retain) NSNumber * viewIndex;
@property (nonatomic, retain) NSNumber * uploadRetryCount;
@property (nonatomic, retain) NSString * mkey;
@property (nonatomic, retain) NSSet *videos;



// Finders
+ (NSArray *)all;
+ (instancetype)findWithId:(NSString *)idTbm;
+ (instancetype)findWithOutgoingVideoId:(NSString *)videoId;
+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex;
+ (instancetype)findWithMkey:(NSString *)mkey;
+ (NSUInteger)count;

// Incoming videos
- (NSArray *) sortedIncomingVideos;
- (TBMVideo *) oldestIncomingVideo;
- (TBMVideo *) newestIncomingVideo;
- (BOOL) hasIncomingVideoId:(NSString *)videoId;
- (BOOL) isNewestIncomingVideo:(TBMVideo *)video;
- (TBMVideo *) createIncomingVideoWithVideoId:(NSString *)videoId;
- (TBMVideo *) firstPlayableVideo;
- (TBMVideo *) nextPlayableVideoAfterVideo:(TBMVideo *)video;
- (void) deleteAllViewedVideos;

// Create and destroy
+ (instancetype)newWithId:(NSNumber *)idTbm;
+ (NSUInteger)destroyAll;
+ (void)destroyWithId:(NSNumber *)idTbm;
+ (void)saveAll;

// VideoStatusNotification
+ (void)addVideoStatusNotificationDelegate:(id)delegate;
+ (void)removeVideoStatusNotificationDelegate:(id)delegate;

- (UIImage *)thumbImageOrThumbMissingImage;

- (NSString *)videoStatusString;
// Probably should not expose this and rather have setters for various states.
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId;
- (void)setAndNotifyUploadRetryCount:(NSNumber *)retryCount videoId:(NSString *)videoId;
- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)status video:(TBMVideo *)video;
- (void)setAndNotifyDownloadRetryCount:(NSNumber *)retryCount video:(TBMVideo *)video;

- (void)setViewedWithIncomingVideo:(TBMVideo *)video;
- (BOOL)incomingVideoNotViewed;

- (void)handleAfterOutgoingVideoCreated;

@end


@interface TBMFriend (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(TBMVideo *)value;
- (void)removeChildrenObject:(TBMVideo *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;
@end


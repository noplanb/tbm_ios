//
//  TBMVideo.h
//  tbm
//
//  Created by Sani Elfishawy on 8/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "_TBMVideo.h"

@class TBMFriend;

@interface TBMVideo : _TBMVideo

// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
typedef NS_ENUM (NSInteger, TBMIncomingVideoStatus) {
    INCOMING_VIDEO_STATUS_NEW,
    INCOMING_VIDEO_STATUS_DOWNLOADING,
    INCOMING_VIDEO_STATUS_DOWNLOADED,
    INCOMING_VIDEO_STATUS_VIEWED,
    INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY
};

// Class methods
+ (instancetype)newWithVideoId:(NSString *)videoId;
+ (instancetype)findWithVideoId:(NSString *)videoId;
+ (NSArray *)downloadedUnviewed;
+ (NSUInteger)downloadedUnviewedCount;
+ (NSArray *)downloading;
+ (NSUInteger)downloadingCount;
+ (NSUInteger)unviewedCount;
+ (NSArray *)all;
+ (void)printAll;
+ (NSUInteger)count;
+ (void) destroy:(TBMVideo *)video;

// Instance methods

// Video file
- (NSURL *)videoUrl;
- (NSString *)videoPath;
- (BOOL)videoFileExists;
- (unsigned long long)videoFileSize;
- (BOOL) hasValidVideoFile;
- (void)deleteVideoFile;
- (void)deleteFiles;

// Thumb file
- (NSURL *)thumbUrl;
- (NSString *)thumbPath;
- (BOOL)hasThumb;
- (BOOL)generateThumb;
- (void)deleteThumbFile;

- (BOOL)isStatusDownloading;
- (NSString *)statusName;
+ (NSString *)nameForStatus:(TBMIncomingVideoStatus)statusж;

@end

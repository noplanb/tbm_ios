//
//  TBMVideo.h
//  tbm
//
//  Created by Sani Elfishawy on 8/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBMFriend;

@interface TBMVideo : NSManagedObject

// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
typedef NS_ENUM (NSInteger, TBMIncomingVideoStatus) {
    INCOMING_VIDEO_STATUS_NEW,
    INCOMING_VIDEO_STATUS_DOWNLOADING,
    INCOMING_VIDEO_STATUS_DOWNLOADED,
    INCOMING_VIDEO_STATUS_VIEWED,
    INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY
};

@property (nonatomic) TBMIncomingVideoStatus status;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSNumber * downloadRetryCount;
@property (nonatomic) TBMFriend *friend;

// Class methods
+ (instancetype)newWithVideoId:(NSString *)videoId;
+ (instancetype)findWithVideoId:(NSString *)videoId;
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
- (void)generateThumb;
- (void)deleteThumbFile;

@end

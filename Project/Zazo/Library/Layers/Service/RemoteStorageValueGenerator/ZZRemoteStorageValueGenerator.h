//
//  ZZRemoteStorageValueGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


@class TBMFriend;
@class TBMVideo;

//--------------------------------------
// Remote data structure keys and values
//--------------------------------------
static BOOL REMOTE_STORAGE_USE_S3 = YES;
static NSString *REMOTE_STORAGE_S3_BASE_URL_STRING = @"s3://";

static NSString *REMOTE_STORAGE_SERVER_VIDEO_UPLOAD_PATH = @"videos/create";
static NSString *REMOTE_STORAGE_SERVER_VIDEO_DOWNLOAD_PATH = @"videos/get";

static NSString *REMOTE_STORAGE_VIDEO_ID_KEY = @"videoId";
static NSString *REMOTE_STORAGE_STATUS_KEY = @"status";

static NSString * REMOTE_STORAGE_STATUS_DOWNLOADED = @"downloaded";
static NSString * REMOTE_STORAGE_STATUS_VIEWED = @"viewed";

static NSString * REMOTE_STORAGE_STATUS_SUFFIX = @"-VideoStatusKVKey";
static NSString * REMOTE_STORAGE_VIDEO_ID_SUFFIX = @"-VideoIdKVKey";

@interface ZZRemoteStorageValueGenerator : NSObject

+ (NSString*)fileTransferRemoteUrlBase;
+ (NSString*)fileTransferUploadPath;
+ (NSString*)fileTransferDownloadPath;
+ (NSString*)fileTransferDeletePath;

+ (NSString*)outgoingVideoRemoteFilename:(TBMFriend *)friend videoId:(NSString *)videoId;
+ (NSString*)incomingVideoRemoteFilename:(TBMVideo *)video;


+ (NSString *)outgoingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)incomingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)incomingVideoStatusRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend;


@end

//
//  TBMRemoteStorageHandler.h
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMVideo.h"

@class TBMFriend;

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

@interface TBMRemoteStorageHandler : NSObject


+ (NSString *) fileTransferRemoteUrlBase;
+ (NSString *) fileTransferUploadPath;
+ (NSString *) fileTransferDownloadPath;
+ (NSString *) fileTransferDeletePath;

+ (NSString *)outgoingVideoRemoteFilename:(TBMFriend *)friend videoID:(NSString *)videoID;
+ (NSString *) incomingVideoRemoteFilename:(TBMVideo *)video;

// Convenience setters
+ (void)addRemoteOutgoingVideoID:(NSString *)videoID friend:(TBMFriend *)friend;
+ (void)deleteRemoteIncomingVideoID:(NSString *)videoID friend:(TBMFriend *)friend;
+ (void)setRemoteIncomingVideoStatus:(NSString *)status videoID:(NSString *)videoID friend:(TBMFriend *)friend;

// Convenience getters
+ (void)getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void (^)(NSArray *videoIds))gotVideoIds;
+ (void) getRemoteOutgoingVideoStatus:(TBMFriend *)friend success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure;
+ (void)getAllRemoteIncomingVideoIds;
+ (void)getAllRemoteOutgoingVideoStatus;

+ (void)getRemoteEverSentFriendsWithSuccess:(void (^)(NSArray *response))success failure:(void (^)(NSError *error))failure;
+ (void)setRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys;
// Conversion of status
+ (int)outgoingVideoStatusWithRemoteStatus:(NSString *)remoteStatus;


//*****************

+ (NSString *)incomingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)outgoingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)incomingVideoStatusRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend;

@end

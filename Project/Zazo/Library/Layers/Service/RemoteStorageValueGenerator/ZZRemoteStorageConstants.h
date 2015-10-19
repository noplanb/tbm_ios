//
//  ZZRemoteStorageConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZAPIRoutes.h"
#import "ZZKeychainDataProvider.h"

extern const struct ZZRemoteStorageParameters
{
    __unsafe_unretained NSString *key1;
    __unsafe_unretained NSString *key2;
    __unsafe_unretained NSString *value;
    __unsafe_unretained NSString *videoID;
    __unsafe_unretained NSString *status;
    
} ZZRemoteStorageParameters;


#pragma mark - Constants

static BOOL const kRemoteStorageShouldUseS3 = YES;

static NSString* const kRemoteStorageS3Endpoint = @"s3://";
static NSString* const kRemoteStorageApiVideoUploadPath = @"videos/create";
static NSString* const kRemoteStorageApiVideoDownloadPath = @"videos/get";

static NSString *const kRemoteStorageArraySeparator = @",";

//DO NOT CHANGE WITHOUT PERMISSION! I will found you and kill.
static NSString * kRemoteStorageVideoStatusSuffix = @"-VideoStatusKVKey";
static NSString * kRemoteStorageVideoIDSuffix = @"-VideoIdKVKey";


#pragma mark - Remote Video Statuses

typedef NS_ENUM(NSInteger, ZZRemoteStorageVideoStatus)
{
    ZZRemoteStorageVideoStatusNone,
    ZZRemoteStorageVideoStatusDownloaded,
    ZZRemoteStorageVideoStatusViewed
};

NSString* ZZRemoteStorageVideoStatusStringFromEnumValue(ZZRemoteStorageVideoStatus);
ZZRemoteStorageVideoStatus ZZRemoteStorageVideoStatusEnumValueFromSrting(NSString*);



#pragma mark - Endpoints

static inline NSString* const remoteStorageS3Bucket()
{
    return [ZZKeychainDataProvider loadCredentials].bucket;
}

static inline NSString* const remoteStorageBaseURL()
{
    return kRemoteStorageShouldUseS3 ? kRemoteStorageS3Endpoint : apiBaseURL();
}


#pragma mark - CRUD Remote Path

static inline NSString* const remoteStorageFileTransferUploadPath()
{
    return kRemoteStorageShouldUseS3 ? remoteStorageS3Bucket() : kRemoteStorageApiVideoUploadPath;
}

static inline NSString* const remoteStorageFileTransferDownloadPath()
{
    return kRemoteStorageShouldUseS3 ? remoteStorageS3Bucket() : kRemoteStorageApiVideoDownloadPath;
}

static inline NSString* const remoteStorageFileTransferDeletePath()
{
    return remoteStorageS3Bucket();
}


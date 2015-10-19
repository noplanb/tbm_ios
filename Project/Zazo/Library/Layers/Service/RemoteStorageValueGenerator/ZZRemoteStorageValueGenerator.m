//
//  ZZRemoteStorageValueGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageValueGenerator.h"
#import "TBMFriend.h"
#import "ZZUserDataProvider.h"
#import "NSString+ZZAdditions.h"
#import "ZZKeychainDataProvider.h"
#import "ZZAPIRoutes.h"
#import "ZZRemoteStorageConstants.h"

@implementation ZZRemoteStorageValueGenerator

//------------------------
// Keys for remote storage
//------------------------
+ (NSString *)incomingVideoRemoteFilename:(TBMVideo *)video
{
    return [self incomingVideoRemoteFilenameWithFriend:video.friend videoId:video.videoId];
}

+ (NSString *)incomingVideoRemoteFilenameWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId
{
    return [NSString stringWithFormat:@"%@-%@",
            [self incomingPrefix:friend],
            [[friend.ckey stringByAppendingString:videoId] an_md5]];
}

+ (NSString *)outgoingVideoRemoteFilename:(TBMFriend *)friend videoId:(NSString *)videoId
{
    return [NSString stringWithFormat:@"%@-%@",
            [self outgoingPrefix:friend],
            [[friend.ckey stringByAppendingString:videoId] an_md5]];
}

+ (NSString *)incomingVideoIDRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
            [self incomingPrefix:friend],
            [self incomingSuffix:friend withTypeSuffix:REMOTE_STORAGE_VIDEO_ID_SUFFIX]];
}

+ (NSString *)outgoingVideoIDRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
            [self outgoingPrefix:friend],
            [self outgoingSuffix:friend withTypeSuffix:REMOTE_STORAGE_VIDEO_ID_SUFFIX]];
}

+ (NSString *)incomingVideoStatusRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
            [self incomingPrefix:friend],
            [self incomingSuffix:friend withTypeSuffix:REMOTE_STORAGE_STATUS_SUFFIX]];
}

+ (NSString *)outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
            [self outgoingPrefix:friend],
            [self outgoingSuffix:friend withTypeSuffix:REMOTE_STORAGE_STATUS_SUFFIX]];
}

// Helpers

+ (NSString *)incomingPrefix:(TBMFriend *)friend
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    return [NSString stringWithFormat:@"%@-%@", friend.mkey, model.mkey];
}

+ (NSString *)outgoingPrefix:(TBMFriend *)friend
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    return [NSString stringWithFormat:@"%@-%@", model.mkey, friend.mkey];
}

+ (NSString *)incomingSuffix:(TBMFriend *)friend withTypeSuffix:(NSString *)typeSuffix
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    NSString *md5 = [[[friend.mkey stringByAppendingString:model.mkey] stringByAppendingString:friend.ckey] an_md5];
    return [md5 stringByAppendingString:typeSuffix];
}

+ (NSString *)outgoingSuffix:(TBMFriend *)friend withTypeSuffix:(NSString *)typeSuffix
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    NSString *md5 = [[[model.mkey stringByAppendingString:friend.mkey] stringByAppendingString:friend.ckey] an_md5];
    return [md5 stringByAppendingString:typeSuffix];
}


@end

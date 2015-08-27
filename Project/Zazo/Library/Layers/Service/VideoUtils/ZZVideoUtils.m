//
//  ZZVideoUtils.m
//  Zazo
//
//  Created by ANODA on 14/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoUtils.h"
#import "ZZFriendDomainModel.h"
#import "ZZStringUtils.h"
#import "ZZVideoDomainModel.h"
#import "ZZConfig.h"
#import "ZZFriendDataProvider.h"
#import "ZZVideoDataProvider.h"

@implementation ZZVideoUtils

#pragma mark - VideoIds

+ (NSString *)generateId
{
    double seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", seconds * 1000.0];
}

+ (double)timeStampWithVideoId:(NSString *)videoId
{
    return [videoId doubleValue];
}

+ (NSString *)newerVideoId:(NSString *)vid1 otherVideoId:(NSString *)vid2
{
    BOOL isVid1Bigger = [ZZVideoUtils timeStampWithVideoId:vid1] > [ZZVideoUtils timeStampWithVideoId:vid2];
    id retValue = isVid1Bigger ? vid1 : vid2;
    return retValue;
}

+ (BOOL)isvid1:(NSString *)vid1 olderThanVid2:(NSString *)vid2
{
    return [ZZVideoUtils timeStampWithVideoId:vid1] < [ZZVideoUtils timeStampWithVideoId:vid2];
}

+ (BOOL)isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2
{
    return [ZZVideoUtils timeStampWithVideoId:vid1] > [ZZVideoUtils timeStampWithVideoId:vid2];
}

#pragma mark - VideoFile Markers

+ (NSString *)markerWithFriend:(ZZFriendDomainModel *)friend videoId:(NSString *)videoId isUpload:(BOOL)isUpload
{
    return [ZZStringUtils jsonWithDictionary: @{kVideoUtilsFriendIdKey : friend.idTbm,
                                                kVideoUtilsVideoIdKey : videoId,
                                                kIsUploadKey : [NSNumber numberWithBool:isUpload]}];
}

+ (NSString *) markerWithVideo:(ZZVideoDomainModel *)video isUpload:(BOOL)isUpload
{
    return [self markerWithFriend:[video relatedUser] videoId:video.videoID isUpload:isUpload];
}

+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker
{
    return [ZZStringUtils dictionaryWithJson:marker];
}

+ (ZZFriendDomainModel *)friendWithMarker:(NSString *)marker
{
    NSString *friendId = [[ZZVideoUtils friendIdAndVideoIdWithMarker:marker] objectForKey:kVideoUtilsFriendIdKey];
    return [ZZFriendDataProvider friendWithItemID:friendId];
}

+ (ZZVideoDomainModel *)videoWithMarker:(NSString *)marker
{
    return [ZZVideoDataProvider itemWithID:[ZZVideoUtils videoIdWithMarker:marker]];
}

+ (NSString *)videoIdWithMarker:(NSString *)marker
{
    return [[ZZVideoUtils friendIdAndVideoIdWithMarker:marker] objectForKey:kVideoUtilsVideoIdKey];
}

+ (BOOL)isUploadWithMarker:(NSString *)marker
{
    return [[ZZStringUtils dictionaryWithJson:marker][kIsUploadKey] boolValue];
}

#pragma mark - VideoFile URLS

+ (NSURL *)generateOutgoingVideoUrlWithFriend:(ZZFriendDomainModel *)friend
{
    NSString *videoId = [ZZVideoUtils generateId];
    NSString *marker = [ZZVideoUtils markerWithFriend:friend videoId:videoId isUpload:YES];
    return [ZZVideoUtils outgoingVideoUrlWithMarker:marker];
}

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker
{
    return [[[ZZConfig videosDirectoryUrl] URLByAppendingPathComponent:marker] URLByAppendingPathExtension:@"mov"];
}

+ (NSString *)markerWithOutgoingVideoUrl:(NSURL *)url
{
    return [url URLByDeletingPathExtension].lastPathComponent;
}

+ (ZZFriendDomainModel *)friendWithOutgoingVideoUrl:(NSURL *)url
{
    return [ZZVideoUtils friendWithMarker:[ZZVideoUtils markerWithOutgoingVideoUrl:url]];
}

+ (NSString *)videoIdWithOutgoingVideoUrl:(NSURL *)url
{
    return [ZZVideoUtils videoIdWithMarker:[ZZVideoUtils markerWithOutgoingVideoUrl:url]];
}

@end

//
//  TBMVideoIdUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoIdUtils.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"
#import "TBMConfig.h"

@implementation TBMVideoIdUtils

#pragma mark - VideoIds

+ (NSString *)generateId{
    double seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", seconds * 1000.0];
}

+ (double) timeStampWithVideoId:(NSString *)videoId{
    return [videoId doubleValue];
}

+ (NSString *) newerVideoId:(NSString *)vid1 otherVideoId:(NSString *)vid2{
    if ([TBMVideoIdUtils timeStampWithVideoId:vid1] > [TBMVideoIdUtils timeStampWithVideoId:vid2])
        return vid1;
    else
        return vid2;
}

+ (BOOL) isvid1:(NSString *)vid1 olderThanVid2:(NSString *)vid2{
    return [TBMVideoIdUtils timeStampWithVideoId:vid1] < [TBMVideoIdUtils timeStampWithVideoId:vid2];
}

+ (BOOL) isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2{
    return [TBMVideoIdUtils timeStampWithVideoId:vid1] > [TBMVideoIdUtils timeStampWithVideoId:vid2];
}

#pragma mark - VideoFile Markers

+ (NSString *)markerWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId isUpload:(BOOL)isUpload{
    return [TBMStringUtils jsonWithDictionary: @{
                                                 VIDEO_ID_UTILS_FRIEND_ID_KEY: friend.idTbm,
                                                 VIDEO_ID_UTILS_VIDEO_ID_KEY: videoId,
                                                 IS_UPLOAD_KEY: [NSNumber numberWithBool:isUpload]
                                                 }];
}

+ (NSString *) markerWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload{
    return [self markerWithFriend:[video friend] videoId:video.videoId isUpload:isUpload];
}

+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker{
    return [TBMStringUtils dictionaryWithJson:marker];
}

+ (TBMFriend *)friendWithMarker:(NSString *)marker{
    NSString *friendId = [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_FRIEND_ID_KEY];
    return [TBMFriend findWithId:friendId];
}

+ (TBMVideo *)videoWithMarker:(NSString *)marker{
    return [TBMVideo findWithVideoId:[TBMVideoIdUtils videoIdWithMarker:marker]];
}

+ (NSString *)videoIdWithMarker:(NSString *)marker{
    return [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_VIDEO_ID_KEY];
}

+ (BOOL)isUploadWithMarker:(NSString *)marker{
    return [[TBMStringUtils dictionaryWithJson:marker][IS_UPLOAD_KEY] boolValue];
}

#pragma mark - VideoFile URLS

+ (NSURL *)generateOutgoingVideoUrlWithFriend:(TBMFriend *)friend{
    NSString *videoId = [TBMVideoIdUtils generateId];
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:videoId isUpload:YES];
    return [TBMVideoIdUtils outgoingVideoUrlWithMarker:marker];
}

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker{
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:marker];
}

+ (NSString *)markerWithOutgoingVideoUrl:(NSURL *)url{
    return url.lastPathComponent;
}

+ (TBMFriend *)friendWithOutgoingVideoUrl:(NSURL *)url{
    return [TBMVideoIdUtils friendWithMarker:[TBMVideoIdUtils markerWithOutgoingVideoUrl:url]];
}

+ (NSString *)videoIdWithOutgoingVideoUrl:(NSURL *)url{
    return [TBMVideoIdUtils videoIdWithMarker:[TBMVideoIdUtils markerWithOutgoingVideoUrl:url]];
}

@end

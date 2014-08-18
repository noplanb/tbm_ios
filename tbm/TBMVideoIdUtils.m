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

@implementation TBMVideoIdUtils

+ (NSString *)generateId{
    double seconds = [[NSDate date] timeIntervalSinceReferenceDate];
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

+ (NSString *)markerWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId{
    return [TBMStringUtils jsonWithDictionary: @{VIDEO_ID_UTILS_FRIEND_ID_KEY: friend.idTbm, VIDEO_ID_UTILS_VIDEO_ID_KEY: videoId}];
}

+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker{
    return [TBMStringUtils dictionaryWithJson:marker];
}

+ (TBMFriend *)friendWithMarker:(NSString *)marker{
    NSString *friendId = [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_FRIEND_ID_KEY];
    return [TBMFriend findWithId:friendId];
}

+ (TBMVideo *)videoWithMarker:(NSString *)marker{
    NSString *videoId = [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_VIDEO_ID_KEY];
    return [TBMVideo findWithVideoId:videoId];
}

+ (NSString *)videoIdWithMarker:(NSString *)marker{
    return [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_VIDEO_ID_KEY];
}

@end

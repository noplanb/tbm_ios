//
//  TBMVideoIdUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"
#import "TBMVideo.h"

static NSString *VIDEO_ID_UTILS_VIDEO_ID_KEY = @"videoId";
static NSString *VIDEO_ID_UTILS_FRIEND_ID_KEY = @"friendId";
static NSString *IS_UPLOAD_KEY = @"isUpload";


@interface TBMVideoIdUtils : NSObject

+ (NSString *)generateId;
+ (double) timeStampWithVideoId:(NSString *)videoId;
+ (NSString *) newerVideoId:(NSString *)vid1 otherVideoId:(NSString *)vid2;
+ (BOOL) isvid1:(NSString *)vid1 olderThanVid2:(NSString *)vid2;
+ (BOOL) isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2;
+ (NSString *)markerWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId isUpload:(BOOL)isUpload;
+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker;
+ (NSString *)videoIdWithMarker:(NSString *)marker;
+ (TBMFriend *)friendWithMarker:(NSString *)marker;
+ (BOOL)isUploadWithMarker:(NSString *)marker;
+ (TBMVideo *)videoWithMarker:(NSString *)marker;
@end

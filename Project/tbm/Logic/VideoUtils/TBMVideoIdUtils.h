//
//  TBMVideoIdUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriend.h"
#import "TBMVideo.h"
#import "ZZFileTransferMarkerDomainModel.h"

static NSString *VIDEO_ID_UTILS_VIDEO_ID_KEY = @"videoId";
static NSString *VIDEO_ID_UTILS_FRIEND_ID_KEY = @"friendId";
static NSString *IS_UPLOAD_KEY = @"isUpload";

@interface TBMVideoIdUtils : NSObject

+ (NSString*)markerWithFriendID:(NSString*)friendID videoID:(NSString *)videoID isUpload:(BOOL)isUpload;
+ (NSURL*)generateOutgoingVideoUrlWithFriendID:(NSString*)friendID;
+ (ZZFileTransferMarkerDomainModel*)markerModelWithOutgoingVideoURL:(NSURL*)url;


+ (NSString *)generateId;
+ (double) timeStampWithVideoId:(NSString *)videoId;
+ (BOOL) isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2;

+ (NSURL*)outgoingVideoUrlWithMarker:(NSString *)marker;

@end

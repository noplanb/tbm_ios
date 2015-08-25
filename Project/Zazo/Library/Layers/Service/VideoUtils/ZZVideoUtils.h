//
//  ZZVideoUtils.h
//  Zazo
//
//  Created by ANODA on 14/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kVideoUtilsVideoIdKey = @"videoId";
static NSString* const kVideoUtilsFriendIdKey = @"friendId";
static NSString* const kIsUploadKey = @"isUpload";

@class ZZFriendDomainModel, ZZVideoDomainModel;

@interface ZZVideoUtils : NSObject

+ (NSString *)generateId;
+ (double) timeStampWithVideoId:(NSString *)videoId;
+ (NSString *) newerVideoId:(NSString *)vid1 otherVideoId:(NSString *)vid2;
+ (BOOL) isvid1:(NSString *)vid1 olderThanVid2:(NSString *)vid2;
+ (BOOL) isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2;
+ (NSString *)markerWithFriend:(ZZFriendDomainModel *)friend videoId:(NSString *)videoId isUpload:(BOOL)isUpload;
+ (NSString *) markerWithVideo:(ZZVideoDomainModel *)video isUpload:(BOOL)isUpload;
+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker;
+ (NSString *)videoIdWithMarker:(NSString *)marker;
+ (ZZFriendDomainModel *)friendWithMarker:(NSString *)marker;
+ (BOOL)isUploadWithMarker:(NSString *)marker;
+ (ZZVideoDomainModel *)videoWithMarker:(NSString *)marker;
+ (NSURL *)generateOutgoingVideoUrlWithFriend:(ZZFriendDomainModel *)friend;
+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker;
+ (NSString *)markerWithOutgoingVideoUrl:(NSURL *)url;
+ (ZZFriendDomainModel *)friendWithOutgoingVideoUrl:(NSURL *)url;
+ (NSString *)videoIdWithOutgoingVideoUrl:(NSURL *)url;

@end

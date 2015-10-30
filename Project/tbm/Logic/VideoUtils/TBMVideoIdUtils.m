//
//  TBMVideoIdUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoIdUtils.h"
#import "TBMUser.h"
#import "ZZStringUtils.h"
#import "ZZVideoDataProvider.h"
#import "ZZFileTransferMarkerDomainModel.h"
#import "FEMSerializer.h"

@implementation TBMVideoIdUtils

#pragma mark - VideoIds

+ (NSString*)generateId
{
    double seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", seconds * 1000.0];
}

+ (double)timeStampWithVideoId:(NSString *)videoId
{
    return [videoId doubleValue];
}

+ (NSURL*)generateOutgoingVideoUrlWithFriendID:(NSString*)friendID
{
    NSString *videoId = [TBMVideoIdUtils generateId];
    NSString *marker = [TBMVideoIdUtils markerWithFriendID:friendID videoID:videoId isUpload:YES];
    return [TBMVideoIdUtils outgoingVideoUrlWithMarker:marker];
}

+ (NSString*)markerWithFriendID:(NSString*)friendID videoID:(NSString *)videoID isUpload:(BOOL)isUpload
{
    ZZFileTransferMarkerDomainModel* marker = [ZZFileTransferMarkerDomainModel new];
    marker.friendID = friendID;
    marker.videoID = videoID;
    marker.isUpload = isUpload;
    
    NSDictionary* dict = [FEMSerializer serializeObject:marker usingMapping:(id)[ZZFileTransferMarkerDomainModel mapping]];
    
    return [ZZStringUtils jsonWithDictionary:dict];
}

+ (BOOL)isvid1:(NSString *)vid1 newerThanVid2:(NSString *)vid2
{
    return [TBMVideoIdUtils timeStampWithVideoId:vid1] > [TBMVideoIdUtils timeStampWithVideoId:vid2];
}










//+ (NSString *) newerVideoId:(NSString *)vid1 otherVideoId:(NSString *)vid2
//{
//    if ([TBMVideoIdUtils timeStampWithVideoId:vid1] > [TBMVideoIdUtils timeStampWithVideoId:vid2])
//        return vid1;
//    else
//        return vid2;
//}

//+ (BOOL) isvid1:(NSString *)vid1 olderThanVid2:(NSString *)vid2{
//    return [TBMVideoIdUtils timeStampWithVideoId:vid1] < [TBMVideoIdUtils timeStampWithVideoId:vid2];
//}



#pragma mark - VideoFile Markers

//
//+ (NSString*) markerWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload
//{
//    return [self markerWithFriendID:[video friend].idTbm videoID:video.videoId isUpload:isUpload];
//}

//+ (NSDictionary *)friendIdAndVideoIdWithMarker:(NSString *)marker
//{
//    return [ZZStringUtils dictionaryWithJson:marker];
//}

//+ (TBMFriend *)friendWithMarker:(NSString *)marker
//{
//    NSString *friendId = [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_FRIEND_ID_KEY];
//    return [TBMFriend findWithId:friendId];
//}

//+ (TBMVideo *)videoWithMarker:(NSString *)marker{
//    
//    return [ZZVideoDataProvider findWithVideoId:[TBMVideoIdUtils videoIdWithMarker:marker]];
//}

//+ (NSString *)videoIdWithMarker:(NSString *)marker{
//    return [[TBMVideoIdUtils friendIdAndVideoIdWithMarker:marker] objectForKey:VIDEO_ID_UTILS_VIDEO_ID_KEY];
//}

//+ (BOOL)isUploadWithMarker:(NSString *)marker{
//    return [[ZZStringUtils dictionaryWithJson:marker][IS_UPLOAD_KEY] boolValue];
//}

#pragma mark - VideoFile URLS



+ (NSURL*)outgoingVideoUrlWithMarker:(NSString*)marker
{
     NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [[videosURL URLByAppendingPathComponent:marker] URLByAppendingPathExtension:@"mov"];
}

+ (ZZFileTransferMarkerDomainModel*)markerModelWithOutgoingVideoURL:(NSURL*)url
{
    NSString* marker = [url URLByDeletingPathExtension].lastPathComponent;
    return [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];
}

//+ (TBMFriend *)friendWithOutgoingVideoUrl:(NSURL *)url
//{
////    return [TBMVideoIdUtils friendWithMarker:[TBMVideoIdUtils markerWithOutgoingVideoUrl:url]];
////}
//
//+ (NSString *)videoIdWithOutgoingVideoUrl:(NSURL *)url
//{
//    return [TBMVideoIdUtils videoIdWithMarker:[TBMVideoIdUtils markerWithOutgoingVideoUrl:url]];
//}

@end

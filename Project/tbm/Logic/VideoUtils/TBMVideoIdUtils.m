//
//  TBMVideoIDUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoIDUtils.h"
#import "TBMUser.h"
#import "ZZStringUtils.h"
#import "ZZVideoDataProvider.h"
#import "ZZFileTransferMarkerDomainModel.h"
#import "FEMSerializer.h"

@implementation TBMVideoIDUtils

#pragma mark - VideoIds

+ (NSString*)generateId
{
    double seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", seconds * 1000.0];
}

+ (double)timeStampWithVideoID:(NSString *)videoID
{
    return [videoID doubleValue];
}

+ (NSURL*)generateOutgoingVideoUrlWithFriendID:(NSString*)friendID
{
    NSString *videoID = [TBMVideoIDUtils generateId];
    NSString *marker = [TBMVideoIDUtils markerWithFriendID:friendID videoID:videoID isUpload:YES];
    return [TBMVideoIDUtils outgoingVideoUrlWithMarker:marker];
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
    return [TBMVideoIDUtils timeStampWithVideoID:vid1] > [TBMVideoIDUtils timeStampWithVideoID:vid2];
}

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

@end

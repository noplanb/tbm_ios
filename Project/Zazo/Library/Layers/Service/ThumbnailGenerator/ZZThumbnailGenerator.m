//
//  ZZThumbnailGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZThumbnailGenerator.h"
#import "TBMVideo.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoDomainModel.h"
#import "ZZFileHelper.h"
#import "ZZVideoDataProvider.h"

@implementation ZZThumbnailGenerator


#pragma mark Thumb

+ (UIImage*)thumbImageForUser:(ZZFriendDomainModel*)friend
{
    if ([self hasLastThumbForUser:friend])
    {
        return [self lastThumbImageForUser:friend];
    }
    else if ([self legacyThumbImageForFriend:friend])
    {
        return [self legacyThumbImageForFriend:friend];
    }
    return nil;
}

+ (BOOL)isThumbNoPicForUser:(ZZFriendDomainModel*)friend
{
    return ![self hasLastThumbForUser:friend] && ![self hasLegacyThumbForUser:friend];
}

+ (void)generateThumbVideo:(ZZVideoDomainModel*)video
{
    OB_INFO(@"generateThumbWithVideo: %@ vid:%@", video.relatedUser.firstName, video.videoID);
    if ([self _generateThumbForVideo:video])
    {
        [self _copyToLastThumbWithVideo:video];
    }
    else
    {
    
    }
}

+ (void)_copyToLastThumbWithVideo:(ZZVideoDomainModel*)video
{
    if ([self hasThumbForVideo:video])
    {
        [self deleteLastThumbForUser:video.relatedUser];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:[self thumbUrlForVideo:video] toURL:[self lastThumbUrlForForUser:video.relatedUser] error:&error];
        if (error != nil)
        {
            OB_ERROR(@"copyToLastThumbWithVideo: %@ vid:%@ %@", video.relatedUser.firstName, video.videoID, error);
        }
    }
}

+ (NSURL*)lastThumbUrlForForUser:(ZZFriendDomainModel*)friend
{
    NSString *filename = [NSString stringWithFormat:@"lastThumbFromFriend_%@", friend.idTbm];
    return [ZZFileHelper fileURLInDocumentsDirectoryWithName:filename];
}

+ (UIImage*)lastThumbImageForUser:(ZZFriendDomainModel*)friend
{
    
    UIImage* image = [UIImage imageWithContentsOfFile:[self lastThumbUrlForForUser:friend].path];
    return image;
}

+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel*)friend
{
    return [ZZFileHelper isFileExistsAtURL:[self lastThumbUrlForForUser:friend]];
}

+ (void)deleteLastThumbForUser:(ZZFriendDomainModel*)friend
{
    [ZZFileHelper deleteFileWithURL:[self lastThumbUrlForForUser:friend]];
}

+ (UIImage*)legacyThumbImageForFriend:(ZZFriendDomainModel*)friendModel
{
    UIImage *thumbImage = nil;
    NSURL *thumbUrl = nil;
    
    NSArray* videos = [ZZVideoDataProvider sortedIncomingVideosForUser:friendModel];
    
    for (ZZVideoDomainModel *video in videos)
    {
        if ([self hasThumbForVideo:video])
        {
            thumbUrl = [self thumbUrlForVideo:video];
        }
    }
    if (thumbUrl != nil)
    {
        thumbImage = [UIImage imageWithContentsOfFile:thumbUrl.path];
    }
    return thumbImage;
}

+ (BOOL)hasLegacyThumbForUser:(ZZFriendDomainModel*)friend
{
    return ([self legacyThumbImageForFriend:friend] != nil);
}


#pragma mark - Video 

+ (NSURL*)thumbUrlForVideo:(ZZVideoDomainModel*)video
{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend_%@-VideoId_%@", video.relatedUser.idTbm, video.videoID];
    NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

+ (NSString*)thumbPathForVideo:(ZZVideoDomainModel*)video
{
    return [self thumbUrlForVideo:video].path;
}

+ (BOOL)hasThumbForVideo:(ZZVideoDomainModel*)video
{
    return [ZZFileHelper isFileExistsAtURL:[self thumbUrlForVideo:video]];
}

+ (BOOL)_generateThumbForVideo:(ZZVideoDomainModel*)video
{
    DebugLog(@"generateThumb vid: %@ for %@", video.videoID, video.relatedUser.firstName);
    if (![ZZFileHelper isFileValidWithFileURL:video.videoURL])
    {
        OB_ERROR(@"generateThumb: vid: %@ !hasValidVideoFile", video.videoID);
        return NO;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:video.videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CMTime secondsFromEnd = CMTimeMake(2, 1);
    CMTime thumbTime = CMTimeSubtract(duration, secondsFromEnd);
    CMTime actual;
    NSError *err = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actual error:&err];
    if (err != nil){
        OB_ERROR(@"generateThumb: %@", err);
        return NO;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrlForVideo:video] atomically:YES];
    return YES;
}

+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel*)video
{
    DebugLog(@"deleteThumbFile");
    [ZZFileHelper deleteFileWithURL:[self thumbUrlForVideo:video]];
}


@end

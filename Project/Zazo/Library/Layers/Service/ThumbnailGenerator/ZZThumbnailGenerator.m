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

+ (UIImage *)thumbImageForUser:(ZZFriendDomainModel *)friend
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

+ (BOOL)isThumbNoPicForUser:(ZZFriendDomainModel *)friend
{
    return ![self hasLastThumbForUser:friend] && ![self hasLegacyThumbForUser:friend];
}

+ (BOOL)generateThumbVideo:(ZZVideoDomainModel *)video
{
    ZZLogInfo(@"generateThumbWithVideo: %@ vid:%@", video.relatedUserID, video.videoID);
    if ([self _generateThumbForVideo:video])
    {
        [self _copyToLastThumbWithVideo:video];
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (void)_copyToLastThumbWithVideo:(ZZVideoDomainModel *)video
{
    if ([self hasThumbForVideo:video])
    {
        [self deleteLastThumbForUserWithID:video.relatedUserID];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:[self thumbUrlForVideo:video] toURL:[self lastThumbUrlForForUserWithID:video.relatedUserID] error:&error];
        if (error != nil)
        {
            ZZLogError(@"copyToLastThumbWithVideo: %@ vid:%@ %@", video.relatedUserID, video.videoID, error);
        }
    }
}

+ (NSURL *)lastThumbUrlForForUserWithID:(NSString *)friendID
{
    NSString *filename = [NSString stringWithFormat:@"lastThumbFromFriend_%@", friendID];
    return [ZZFileHelper fileURLInDocumentsDirectoryWithName:filename];
}

+ (UIImage *)lastThumbImageForUser:(ZZFriendDomainModel *)friend
{
    UIImage *image = [UIImage imageWithContentsOfFile:[self lastThumbUrlForForUserWithID:friend.idTbm].path];
    return image;
}

+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel *)friend
{
    return [ZZFileHelper isFileExistsAtURL:[self lastThumbUrlForForUserWithID:friend.idTbm]];
}

+ (void)deleteLastThumbForUserWithID:(NSString *)friendID
{
    [ZZFileHelper deleteFileWithURL:[self lastThumbUrlForForUserWithID:friendID]];
}

+ (UIImage *)legacyThumbImageForFriend:(ZZFriendDomainModel *)friendModel
{
    UIImage *thumbImage = nil;
    NSURL *thumbUrl = nil;

    NSArray *videos = [ZZVideoDataProvider sortedIncomingVideosForUserWithID:friendModel.idTbm];

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

+ (BOOL)hasLegacyThumbForUser:(ZZFriendDomainModel *)friend
{
    return ([self legacyThumbImageForFriend:friend] != nil);
}

+ (UIImage *)thumbnailPlaceholderImage
{
    NSUInteger number = arc4random_uniform(4) + 1;
    return [[UIImage imageNamed:[NSString stringWithFormat:@"contact-pattern-%lu", (unsigned long)number]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


#pragma mark - Video 

+ (NSURL *)thumbUrlForVideo:(ZZVideoDomainModel *)video
{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend_%@-VideoId_%@", video.relatedUserID, video.videoID];
    NSURL *videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

+ (NSString *)thumbPathForVideo:(ZZVideoDomainModel *)video
{
    return [self thumbUrlForVideo:video].path;
}

+ (BOOL)hasThumbForVideo:(ZZVideoDomainModel *)video
{
    return [ZZFileHelper isFileExistsAtURL:[self thumbUrlForVideo:video]];
}

+ (BOOL)_generateThumbForVideo:(ZZVideoDomainModel *)video
{
    ZZLogInfo(@"generateThumb vid: %@ for %@", video.videoID, video.relatedUserID);
    if (![ZZFileHelper isFileValidWithFileURL:video.videoURL])
    {
        ZZLogInfo(@"generateThumb: vid: %@ !hasValidVideoFile", video.videoID);
        return NO;
    }

    AVAsset *asset = [AVAsset assetWithURL:video.videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CMTime secondsFromEnd = CMTimeMake(2, 1);
    CMTime thumbTime = CMTimeSubtract(duration, secondsFromEnd);
    CMTime actual;
    NSError *err = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actual error:&err];
    if (err != nil)
    {
        ZZLogError(@"generateThumb: %@", err);
        return NO;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrlForVideo:video] atomically:YES];
    return YES;
}

+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel *)video
{
    ZZLogInfo(@"deleteThumbFile");
    [ZZFileHelper deleteFileWithURL:[self thumbUrlForVideo:video]];
}


@end

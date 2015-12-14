//
//  ZZThumbnailGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZThumbnailGenerator.h"
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
    else if ([self _hasLegacyThumbForFriend:friend])
    {
        return [self _legacyThumbImageForFriend:friend];
    }
    return nil;
}

+ (BOOL)isThumbNoPicForUser:(ZZFriendDomainModel*)friend
{
    return ![self hasLastThumbForUser:friend] && ![self _hasLegacyThumbForFriend:friend];
}

+ (BOOL)generateThumbVideo:(ZZVideoDomainModel*)video
{
    ZZLogInfo(@"generateThumbWithVideo: %@ vid:%@", video.relatedUser.firstName, video.videoID);
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

+ (void)_copyToLastThumbWithVideo:(ZZVideoDomainModel*)video
{
    if ([self hasThumbForVideo:video])
    {
        [self _deleteLastThumbForUserID:video.relatedUserID];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:[self thumbUrlForVideo:video] toURL:[self lastThumbUrlForForUserID:video.relatedUserID] error:&error];

        if (error != nil)
        {
            ZZLogError(@"copyToLastThumbWithVideo: %@ vid:%@ %@", video.relatedUser.firstName, video.videoID, error);
        }
    }
}

+ (NSURL*)lastThumbUrlForForUser:(ZZFriendDomainModel*)friend
{
    return [self lastThumbUrlForForUserID:friend.idTbm];
}

+ (NSURL*)lastThumbUrlForForUserID:(NSString*)userID
{
    NSString* filename = [NSString stringWithFormat:@"lastThumbFromFriend_%@", userID];
    NSURL* url = [ZZFileHelper fileURLInDocumentsDirectoryWithName:filename];
    
    return url;
}

+ (UIImage*)lastThumbImageForUser:(ZZFriendDomainModel*)friend
{
    NSString *filePath = [self lastThumbUrlForForUser:friend].path;
    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

+ (UIImage*)thumbImageForVideo:(ZZVideoDomainModel*)video
{
    NSString *filePath = [self thumbUrlForVideo:video].path;
    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel*)friend
{
    NSURL* fileURL = [self lastThumbUrlForForUser:friend];
    BOOL ret = [ZZFileHelper isFileExistsAtURL:fileURL];
    return ret;
}

+ (void)_deleteLastThumbForUserID:(NSString*)userID
{
    [ZZFileHelper deleteFileWithURL:[self lastThumbUrlForForUserID:userID]];
}

+ (NSURL*)_legacyThumbURLForFriend:(ZZFriendDomainModel*)friendModel
{
    NSURL *thumbUrl = nil;
    
    NSArray* videos = [ZZVideoDataProvider sortedIncomingVideosForUser:friendModel];
    
    for (ZZVideoDomainModel *video in videos)
    {
        if ([self hasThumbForVideo:video])
        {
            thumbUrl = [self thumbUrlForVideo:video];
        }
    }
    return thumbUrl;
}

+ (UIImage*)_legacyThumbImageForFriend:(ZZFriendDomainModel*)friendModel
{
    UIImage *thumbImage = nil;
    NSURL *thumbUrl = [self _legacyThumbURLForFriend:friendModel];
    
    if (thumbUrl) {
        thumbImage = [UIImage imageWithContentsOfFile:thumbUrl.path];
    }

    return thumbImage;
}

+ (BOOL)_hasLegacyThumbForFriend:(ZZFriendDomainModel*)friend
{
    NSURL* fileURL = [self _legacyThumbURLForFriend:friend];
    BOOL ret = [ZZFileHelper isFileExistsAtURL:fileURL];
    return ret;
}


#pragma mark - Video 

+ (NSURL*)thumbUrlForVideo:(ZZVideoDomainModel*)video
{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend_%@-VideoId_%@", video.relatedUserID, video.videoID];
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
    ZZLogInfo(@"generateThumb vid: %@ for %@", video.videoID, video.relatedUser.firstName);
    if (![ZZFileHelper isFileValidWithFileURL:video.videoURL])
    {
        ZZLogInfo(@"generateThumb: vid: %@ !hasValidVideoFile", video.videoID);
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

+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel*)video
{
    ZZLogInfo(@"deleteThumbFile");
    [ZZFileHelper deleteFileWithURL:[self thumbUrlForVideo:video]];
}


+(UIImage *)lastThumbImageForFriendWithID:(NSString *)friendID
{
    NSArray *sortedVideoArray = [ZZVideoDataProvider sortedIncomingVideosForUserID:friendID];

    ZZVideoDomainModel* lastModel = [sortedVideoArray lastObject];

    if (![self hasThumbForVideo:lastModel])
    {
        [self generateThumbVideo:lastModel];
    }

    //TODO: figure out what to do with last thumb image
    //[ZZThumbnailGenerator lastThumbImageForUser:self.item.relatedUser];
    UIImage *image = [self thumbImageForVideo:lastModel];
    return image;
}

@end

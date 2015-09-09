//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZGridCellViewModel.h"
#import "ZZVideoPlayer.h"
#import "NSObject+ANSafeValues.h"

@interface ZZGridCellViewModel ()

@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;

@end

@implementation ZZGridCellViewModel

- (void)updateRecordingStateTo:(BOOL)isRecording
{
    [self.delegate recordingStateUpdatedToState:isRecording viewModel:self];
}

//- (void)stopRecording
//{
//    [self.delegate recordingStateUpdatedToState:NO viewModel:self];
////    self.hasUploadedVideo = YES; // TODO:
//}

- (ZZGridCellViewModelState)state
{
    
    if (!self.item.relatedUser)
    {
        return ZZGridCellViewModelStateAdd;
    }
    else if (self.item.relatedUser.videos.count > 0) // TODO: this condition only for test!, change it later
    {
        return ZZGridCellViewModelStateIncomingVideoNotViewed;
    }
    else if (self.item.relatedUser.hasApp)
    {
        return ZZGridCellViewModelStateFriendHasApp;
    }
    else if (!self.item.relatedUser.hasApp)
    {
        return ZZGridCellViewModelStateFriendHasNoApp;
    }
    
    return 0;
}

- (void)updateVideoPlayingStateTo:(BOOL)isPlaying
{
    [self.delegate playingStateUpdatedToState:isPlaying viewModel:self];
}

- (void)nudgeSelected
{
    [self.delegate nudgeSelectedWithUserModel:self.item.relatedUser];
}

- (void)togglePlayer
{
    [self.videoPlayer toggle];
}

- (NSString*)firstName
{
    return [NSObject an_safeString:self.item.relatedUser.firstName];
}

- (NSArray*)playerVideoURLs
{
    return [self.item.relatedUser.videos allObjects];
}

- (UIImage*)thumbSnapshot
{
    return [self _generateThumbWithVideoUrl:[[self playerVideoURLs] firstObject]];
}

- (UIImage *)videoThumbnailImage
{
    return [self _generateThumbWithVideoUrl:[[self.item.relatedUser.videos allObjects] firstObject]];
}


#pragma mark - Private

- (UIImage *)_generateThumbWithVideoUrl:(NSURL *)videoUrl
{
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CMTime secondsFromEnd = CMTimeMake(2, 1);
    CMTime thumbTime = CMTimeSubtract(duration, secondsFromEnd);
    CMTime actual;
    NSError *err = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actual error:&err];
    if (err != nil){
        OB_ERROR(@"generateThumb: %@", err);
        return nil;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

@end

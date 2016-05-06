//
//  ZZVideoProcessor.m
//  Zazo
//
//  Created by ANODA on 17/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AVFoundation;

#import "ZZVideoProcessor.h"
#import "ZZConfig.h"

static NSString *const kVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
static NSString *const kVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
NSString *const kVideoProcessorErrorReason = @"Problem processing video";

@interface ZZVideoProcessor ()

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSURL *tempVideoUrl;
@property (nonatomic, strong) NSString *marker;
@property (nonatomic, strong) AVAssetExportSession *exportSession;

@end

@implementation ZZVideoProcessor

#pragma mark - Public

- (void)processVideoWithUrl:(NSURL *)url
{
    self.videoUrl = url;
    self.tempVideoUrl = [self generateTempVideoUrl];

    if (![self moveVideoToTemp])
    {
        return;
    }

    [self convertToMpeg4];
}

- (void)convertToMpeg4
{

    [self logFileSize:self.tempVideoUrl];

    AVAsset *asset = [AVAsset assetWithURL:self.tempVideoUrl];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.outputURL = self.videoUrl;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        [self didFinishConvertingToMpeg4];
    }];
}

- (void)didFinishConvertingToMpeg4
{
    if (self.exportSession.status != AVAssetExportSessionStatusCompleted)
    {
        NSString *description = [NSString stringWithFormat:@"export session completed with non complete status: %ld  error: %@", (long)self.exportSession.status, self.exportSession.error];
        NSError *error = [self videoProcessorErrorWithMethod:@"didFinishConvertingToMpeg4" description:description];
        [self handleError:error];
        return;
    }

    [self logFileSize:self.videoUrl];
    [self removeTempFile];

    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFinishProcessing
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:nil]];
}

#pragma mark - Util

- (BOOL)moveVideoToTemp
{

    NSError *error = nil;
    NSError *dontCareError = nil;

    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:&dontCareError];
    [[NSFileManager defaultManager] moveItemAtURL:self.videoUrl toURL:self.tempVideoUrl error:&error];

    if (error != nil)
    {
//        NSError *newError = [NSError errorWithError:error reason:kVideoProcessorErrorReason];
//        [self handleError:newError];
        // TODO: add error handler
        return NO;
    }

    [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:&dontCareError];

    return YES;
}

- (void)logFileSize:(NSURL *)url
{
    NSError *dontCareError = nil;
    [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&dontCareError];
    // TODO: remove this method if we don't need log file size
}

- (NSURL *)generateTempVideoUrl
{
    double seconds = [[NSDate date] timeIntervalSince1970];
    NSString *filename = [NSString stringWithFormat:@"temp_%.0f", seconds * 1000.0];
    NSURL *url = [[ZZConfig videosDirectoryUrl] URLByAppendingPathComponent:filename];

    return [url URLByAppendingPathExtension:@"mov"];
}


#pragma mark Util

- (void)handleError:(NSError *)error
{
    [self handleError:error dispatch:YES];
}

- (void)handleError:(NSError *)error dispatch:(BOOL)dispatch
{
    [self removeTempFile];
    [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFail
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:error]];
}

- (void)removeTempFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:nil];
}

- (NSDictionary *)notificationUserInfoWithError:(NSError *)error
{
    if (error == nil)
    {
        return @{@"videoUrl" : self.videoUrl};
    }
    else
    {
        return @{@"videoUrl" : self.videoUrl, @"error" : error};
    }
}

- (NSError *)videoProcessorErrorWithMethod:(NSString *)method description:(NSString *)description
{
    NSString *domain = [NSString stringWithFormat:@"VideoProcessor#%@", method];
    return [NSError errorWithDomain:domain
                               code:1
                           userInfo:@{
                                   NSLocalizedDescriptionKey : description,
                                   NSLocalizedFailureReasonErrorKey : kVideoProcessorErrorReason
                           }];
}


@end

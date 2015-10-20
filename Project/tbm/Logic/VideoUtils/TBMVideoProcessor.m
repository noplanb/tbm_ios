//
//  TBMVideoProcessor.m
//  Zazo
//
//  Created by Sani Elfishawy on 4/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVideoProcessor.h"
#import "AVFoundation/AVFoundation.h"
#import "OBLogger.h"
#import "NSError+ZZAdditions.h"

NSString* const TBMVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
NSString* const TBMVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
NSString* const TBMVideoProcessorErrorReason = @"Problem processing video";

@interface TBMVideoProcessor ()
@property (nonatomic) NSURL *videoUrl;
@property (nonatomic) NSURL *tempVideoUrl;
@property (nonatomic) NSString *marker;
@property (nonatomic) AVAssetExportSession *exportSession;
@end

@implementation TBMVideoProcessor

#pragma mark - Public

- (void)processVideoWithUrl:(NSURL *)url{
    self.videoUrl = url;
    self.tempVideoUrl = [self generateTempVideoUrl];
    
    if (! [self moveVideoToTemp])
        return;
        
    [self convertToMpeg4];
}


#pragma mark - Conversion

- (void)convertToMpeg4 {
    OB_INFO(@"TBMVideoProcessor: start conversion");
    [self logFileSize:self.tempVideoUrl];
    
    AVAsset *asset = [AVAsset assetWithURL:self.tempVideoUrl];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.outputURL = self.videoUrl;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{[self didFinishConvertingToMpeg4];}];
}

- (void)didFinishConvertingToMpeg4 {
    if (self.exportSession.status != AVAssetExportSessionStatusCompleted) {
        NSString *description = [NSString stringWithFormat:@"export session completed with non complete status: %ld  error: %@", (long)self.exportSession.status, self.exportSession.error];
        NSError *error = [self videoProcessorErrorWithMethod:@"didFinishConvertingToMpeg4" description:description];
        [self handleError:error];
        return;
    }
    OB_INFO(@"TBMVideoProcessor: Successful conversion");
    [self logFileSize:self.videoUrl];
    [self removeTempFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoProcessorDidFinishProcessing
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:nil]];
}


#pragma mark - Util

- (BOOL) moveVideoToTemp{
    NSError *error = nil;
    NSError *dontCareError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:&dontCareError];
    [[NSFileManager defaultManager] moveItemAtURL:self.videoUrl toURL:self.tempVideoUrl error:&error];

    if (error != nil) {
        NSError *newError = [NSError errorWithError:error reason:TBMVideoProcessorErrorReason];
        [self handleError:newError];
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:&dontCareError];
    
    return YES;
}

- (void) logFileSize:(NSURL *)url {
    NSError *dontCareError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&dontCareError];
    if (dontCareError)
        OB_WARN(@"Can't set attributes for file: %@. Error: %@", self.videoUrl.path, dontCareError);
    
    OB_INFO(@"TBMVideoProcessor: filesize %llu", fileAttributes.fileSize);
}

- (NSURL *)generateTempVideoUrl{
    double seconds = [[NSDate date] timeIntervalSince1970];
    NSString *filename =  [NSString stringWithFormat:@"temp_%.0f", seconds * 1000.0];
    
    NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [videosURL URLByAppendingPathComponent:filename];
    return [url URLByAppendingPathExtension:@"mov"];
}


#pragma mark Util
- (void)handleError:(NSError *)error{
    [self handleError:error dispatch:YES];
}

- (void)handleError:(NSError *)error dispatch:(BOOL)dispatch{
    if (dispatch)
        OB_ERROR(@"VideoProcessor: %@", error);
    
    [self removeTempFile];
    [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoProcessorDidFail
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:error]];
}

- (void)removeTempFile{
    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:nil];
}

- (NSDictionary *)notificationUserInfoWithError:(NSError *)error{
    if (error == nil)
        return @{@"videoUrl":self.videoUrl};
    else
        return @{@"videoUrl":self.videoUrl, @"error": error};
}

- (NSError *)videoProcessorErrorWithMethod:(NSString *)method description:(NSString *)description{
    NSString *domain = [NSString stringWithFormat:@"VideoProcessor#%@", method];
    return [NSError errorWithDomain:domain
                               code:1
                           userInfo:@{
                                      NSLocalizedDescriptionKey: description,
                                      NSLocalizedFailureReasonErrorKey: TBMVideoProcessorErrorReason}];
}

@end

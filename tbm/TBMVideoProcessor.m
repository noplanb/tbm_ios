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
#import "TBMConfig.h"

NSString* const TBMVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
NSString* const TBMVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";


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
    
    if (! [self moveVideoToTemp]){
        [self handleError];
        return;
    }
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
        OB_ERROR(@"TBMVideoProcessor: didFinishConvertingToMpeg4 export session completed with non complete status: %ld  error: %@", self.exportSession.status, self.exportSession.error);
        [self handleError];
        return;
    }
    OB_INFO(@"TBMVideoProcessor: Successful conversion");
    [self logFileSize:self.videoUrl];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoProcessorDidFinishProcessing
                                                        object:self
                                                      userInfo:[self notificationUserInfo]];
}


#pragma mark - Util

- (BOOL) moveVideoToTemp{
    NSError *dontCareError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:&dontCareError];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:self.videoUrl toURL:self.tempVideoUrl error:&error];
    if (error) {
        OB_ERROR(@"TBMVideoProcessor: moveVideoToTemp: ERROR: Unable to move video to tempVideoUrl. This should never happen. %@", error);
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
    NSURL *url = [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:filename];
    return [url URLByAppendingPathExtension:@"mov"];
}

- (void)handleError{
    [[NSFileManager defaultManager] removeItemAtURL:self.tempVideoUrl error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoProcessorDidFail
                                                        object:self
                                                      userInfo:[self notificationUserInfo]];
}

- (NSDictionary *)notificationUserInfo{
    return @{@"videoUrl":self.videoUrl};
}

@end

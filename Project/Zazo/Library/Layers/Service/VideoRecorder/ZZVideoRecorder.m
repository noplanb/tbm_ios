//
//  ZZVideoRecorder.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoRecorder.h"
#import "ZZDeviceHandler.h"
#import "ZZGridCell.h"
#import "ZZGridDomainModel.h"
#import "ZZVideoUtils.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoProcessor.h"
#import "ZZGridCellViewModel.h"
#import "SCRecorder.h"
#import "TBMAppDelegate+AppSync.h"
#import "ZZGridCenterCell.h"
#import "ZZGridUIConstants.h"
#import "TBMVideoProcessor.h"

NSString* const kVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";
NSString* const TBMVideoRecorderDidCancelRecording = @"TBMVideoRecorderDidCancelRecording";
NSString* const TBMVideoRecorderDidFail = @"TBMVideoRecorderDidFail";
//NSString* const kZZVideoProcessorErrorReason = @"Problem processing video";

@interface ZZVideoRecorder () <SCRecorderDelegate>

@property (nonatomic, assign) BOOL didCancelRecording;
@property (nonatomic, strong) SCRecorder *recorder;
@property (nonatomic, strong) NSURL* recordVideoUrl;
@property (nonatomic, strong) TBMVideoProcessor* videoProcessor;

@end

@implementation ZZVideoRecorder

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.videoProcessor = [TBMVideoProcessor new];
        self.recorder = [SCRecorder recorder];
        self.recorder.delegate = self;
        self.recorder.captureSessionPreset = AVCaptureSessionPresetLow;
        
        SCAudioConfiguration *audio = self.recorder.audioConfiguration;
        audio.enabled = YES;
        
        SCVideoConfiguration *video = self.recorder.videoConfiguration;
        video.enabled = YES;
        video.scalingMode = AVVideoScalingModeResizeAspectFill;
        
        self.recorder.device = AVCaptureDevicePositionFront;
        self.recorder.session = [SCRecordSession recordSession];
        
        [self.recorder startRunning];
    }
    return self;
}

- (BOOL)areBothCamerasAvailable
{
    return [ZZDeviceHandler areBothCamerasAvailable];
}

- (void)switchCamera
{
    if ([self areBothCamerasAvailable])
    {
        BOOL isFrontCamera = (self.recorder.device == AVCaptureDevicePositionFront);
        AVCaptureDevicePosition camera = isFrontCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        self.recorder.device = camera;
    }
}


#pragma mark - Public Methods

- (void)updateRecordView:(UIView*)recordView
{
    recordView.frame = CGRectMake(0, 0, kGridItemSize().width, kGridItemSize().height);
    self.recorder.previewView = recordView;
}

- (void)startRecordingWithVideoURL:(NSURL*)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    
    [self _startRecordingWithVideoUrl:url];
    [self.recorder.session removeAllSegments];
    
    [self.recorder record];
}


#pragma mark - Start Recording

- (void)_startRecordingWithVideoUrl:(NSURL *)videoUrl
{
    self.recordVideoUrl = videoUrl;
    self.didCancelRecording = NO;
    
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
}


#pragma mark - Stop Recording

- (void)stopRecording
{
    [self.recorder pause];
}

- (void)recorder:(SCRecorder*)recorder didCompleteSegment:(SCRecordSessionSegment*)segment
       inSession:(SCRecordSession*)recordSession error:(NSError*)error
{
    [recordSession mergeSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:^(NSURL *url, NSError *error) {
        if (error == nil) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
            {
                NSLog(@"ok");
                NSError* error;
               if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:self.recordVideoUrl error:&error])
               {
                   NSError* removeError;
                   [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&removeError];
                   
                   [self.videoProcessor processVideoWithUrl:self.recordVideoUrl];
               }
               else
               {
                   NSLog(@"copy error");
               }
            }
            else
            {
                NSLog(@"wrong");
            }
            
        } else {
            
        }
    }];
    
    
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFinishRecording
//                                                        object:self
//                                                      userInfo:@{@"videoUrl": self.recordVideoUrl}];
//    
//    AVAsset *asset = recordSession.assetRepresentingSegments;
//    SCAssetExportSession *assetExportSession = [[SCAssetExportSession alloc] initWithAsset:asset];
//    assetExportSession.outputUrl = self.recordVideoUrl;
//    
//    assetExportSession.outputFileType = AVFileTypeMPEG4;
//    assetExportSession.videoConfiguration.preset = SCPresetLowQuality;
//    assetExportSession.audioConfiguration.preset = SCPresetMediumQuality;
//
//    [assetExportSession exportAsynchronouslyWithCompletionHandler: ^{
//        if (assetExportSession.error == nil) {
//
////            NSError* error;
////            [[NSFileManager defaultManager] moveItemAtURL:videoPath toURL:self.recordVideoUrl error:&error];
////
//            
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.recordVideoUrl path]])
//            {
//                NSLog(@"ok");
//            }
//            else
//            {
//                NSLog(@"wrong");
//            }
//            
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFinishProcessing
//                                                                object:self
//                                                              userInfo:[self notificationUserInfoWithError:nil]];
//           
//        }
//        else
//        {
//            [self handleError:assetExportSession.error dispatch:YES];
//        }
//    }];
}

- (void)handleError:(NSError*)error dispatch:(BOOL)dispatch
{
    [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFail
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:error]];
}

- (NSDictionary *)notificationUserInfoWithError:(NSError *)error
{
    if (error == nil)
    {
        return @{@"videoUrl" : self.recordVideoUrl};
    }
    else
    {
        return @{@"videoUrl" : self.recordVideoUrl, @"error": error};
    }
}


@end

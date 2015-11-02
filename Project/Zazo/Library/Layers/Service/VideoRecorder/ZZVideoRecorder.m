//
//  ZZVideoRecorder.m
//  Zazo
//
//  Created by Sani Elfishawy on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoRecorder.h"
#import "TBMVideoProcessor.h"
#import "PBJVision.h"

NSString* const kVideoProcessorDidFinishProcessing = @"kZZVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"kZZVideoProcessorDidFailProcessing";

NSString* const kZZVideoRecorderDidFinishRecording = @"kZZVideoRecorderDidFinishRecording";
NSString* const kZZVideoRecorderShouldStartRecording = @"kZZVideoRecorderShouldStartRecording";
NSString* const kZZVideoRecorderDidCancelRecording = @"kZZVideoRecorderDidCancelRecording";
NSString* const kZZVideoRecorderDidFail = @"kZZVideoRecorderDidFail";

@interface ZZVideoRecorder () <PBJVisionDelegate>

@property (nonatomic, strong) PBJVision* recorder;
@property (nonatomic, strong) NSURL* recordVideoUrl;
@property (nonatomic, strong) TBMVideoProcessor* videoProcessor;
@property (nonatomic, copy) void (^completionBlock)(BOOL isRecordingSuccess);

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
        self.recorder = [PBJVision sharedInstance];
        self.recorder.delegate = self;
        
        // TODO Sani: make sure all settings are complete
        self.recorder.cameraMode = PBJCameraModeVideo;
        [self.recorder setCameraDevice:PBJCameraDeviceBack];
        self.recorder.cameraOrientation = PBJCameraOrientationPortrait;
        self.recorder.focusMode = PBJFocusModeContinuousAutoFocus;
        self.recorder.outputFormat = PBJOutputFormatStandard;
    }
    return self;
}

#pragma mark - Preview

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return self.recorder.previewLayer;
}

- (void)startPreview{
    [self.recorder startPreview];
}

#pragma mark - Recording

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}



#pragma mark - Camera

- (BOOL)areBothCamerasAvailable
{
    return [self.recorder isCameraDeviceAvailable:PBJCameraDeviceBack] &&
    [self.recorder isCameraDeviceAvailable:PBJCameraDeviceFront];
}

- (void)switchCamera
{
    if (self.recorder.cameraDevice == PBJCameraDeviceFront)
    {
        [self.recorder setCameraDevice:PBJCameraDeviceBack];
    }
    else
    {
        [self.recorder setCameraDevice:PBJCameraDeviceFront];
    }
}


@end

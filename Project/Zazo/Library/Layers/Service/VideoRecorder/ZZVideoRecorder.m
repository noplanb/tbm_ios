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


#pragma mark - PBJVisionDelegate
// session

- (void)visionSessionWillStart:(PBJVision *)vision{}
- (void)visionSessionDidStart:(PBJVision *)vision{}
- (void)visionSessionDidStop:(PBJVision *)vision{}

- (void)visionSessionWasInterrupted:(PBJVision *)vision{}
- (void)visionSessionInterruptionEnded:(PBJVision *)vision{}

// device / mode / format

- (void)visionCameraDeviceWillChange:(PBJVision *)vision{}
- (void)visionCameraDeviceDidChange:(PBJVision *)vision{}

- (void)visionCameraModeWillChange:(PBJVision *)vision{}
- (void)visionCameraModeDidChange:(PBJVision *)vision{}

- (void)visionOutputFormatWillChange:(PBJVision *)vision{}
- (void)visionOutputFormatDidChange:(PBJVision *)vision{}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture{}

- (void)visionDidChangeVideoFormatAndFrameRate:(PBJVision *)vision{}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision{}
- (void)visionDidStopFocus:(PBJVision *)vision{}

- (void)visionWillChangeExposure:(PBJVision *)vision{}
- (void)visionDidChangeExposure:(PBJVision *)vision{}

- (void)visionDidChangeFlashMode:(PBJVision *)vision{} // flash or torch was changed

// authorization / availability

- (void)visionDidChangeAuthorizationStatus:(PBJAuthorizationStatus)status{}
- (void)visionDidChangeFlashAvailablility:(PBJVision *)vision{} // flash or torch is available

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision{}
- (void)visionSessionDidStopPreview:(PBJVision *)vision{}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision{}
- (void)visionDidCapturePhoto:(PBJVision *)vision{}
- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error{}

// video

//- (NSString *)vision:(PBJVision *)vision willStartVideoCaptureToFile:(NSString *)fileName{}
- (void)visionDidStartVideoCapture:(PBJVision *)vision{}
- (void)visionDidPauseVideoCapture:(PBJVision *)vision{} // stopped but not ended
- (void)visionDidResumeVideoCapture:(PBJVision *)vision{}
- (void)visionDidEndVideoCapture:(PBJVision *)vision{}
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error{}

// video capture progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{}
- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer{}


@end

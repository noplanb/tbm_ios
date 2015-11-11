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
#import "iToast.h"
#import "NSError+ZZAdditions.h"
#import "TBMAlertController.h"
#import "ZZSoundEffectPlayer.h"

NSString* const kVideoProcessorDidFinishProcessing = @"kZZVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"kZZVideoProcessorDidFailProcessing";

NSString* const kZZVideoRecorderDidStartVideoCapture = @"kZZVideoRecorderDidStartVideoCapture";
NSString* const kZZVideoRecorderDidEndVideoCapture = @"kZZVideoRecorderDidEndVideoCapture";

static CGFloat const kZZVideoRecorderDelayBeforeNextMessage = 1.1;
static CGFloat const kZZVideoRecorderStartDelayAfterDing = 0.3;
static NSTimeInterval const kZZVideoRecorderMinimumRecordTime = 0.4;

@interface ZZVideoRecorder () <PBJVisionDelegate>

@property (nonatomic, strong) NSURL* recordVideoUrl;
@property (nonatomic, strong) TBMVideoProcessor* videoProcessor;
@property (nonatomic, strong) NSDate* recordStartDate;
@property (nonatomic, copy) void (^completionBlock)(BOOL isRecordingSuccess);
@property (nonatomic, assign) BOOL didCancelRecording;
@property (nonatomic, strong) ZZSoundEffectPlayer *soundPlayer;
@property (nonatomic, assign) BOOL isSetup;
@property (nonatomic, assign) BOOL onCallDialogShowing;
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
        [self _addObservers];
        self.isSetup = NO;
    }
    return self;
}

- (void)setup
{
    if (!self.isSetup)
    {
        self.videoProcessor = [TBMVideoProcessor new];
        self.recorder.delegate = self;
        
        self.recorder.cameraMode = PBJCameraModeVideo;
        [self.recorder setCameraDevice:PBJCameraDeviceFront];
        self.recorder.cameraOrientation = PBJCameraOrientationPortrait;
        self.recorder.focusMode = PBJFocusModeContinuousAutoFocus;
        self.recorder.outputFormat = PBJOutputFormatPreset;
        self.recorder.videoBitRate = PBJVideoBitRate640x480;
        self.recorder.captureSessionPreset = AVCaptureSessionPresetLow;
        self.recorder.usesApplicationAudioSession = YES;
        self.recorder.automaticallyConfiguresApplicationAudioSession = NO;
        self.isSetup = YES;
    }
}

- (PBJVision*)recorder
{
    return [PBJVision sharedInstance];
}

#pragma mark - Preview

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return self.recorder.previewLayer;
}

- (void)startPreview
{
    [self.recorder startPreview];
}

- (void)stopPreview
{
    [self.recorder stopPreview];
}

#pragma mark - Recording indication

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

#pragma mark - Start Recording

- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.didCancelRecording = NO;
    [self _startTouchObserve];
    
    self.recordVideoUrl = url;
    self.completionBlock = completionBlock;

    ANDispatchBlockToMainQueue(^{
        [self.soundPlayer play];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kZZVideoRecorderStartDelayAfterDing * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.recordStartDate = [NSDate date];
        [self.recorder startVideoCapture];
    });
}

#pragma mark - Stop Recording

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.completionBlock = completionBlock;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kZZVideoRecorderStartDelayAfterDing * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Ensure a minimum record time because there are delays to get recording started and stopping before
        // starting can cause problems.
        NSTimeInterval recordTime = [[NSDate date] timeIntervalSinceDate:self.recordStartDate];
        NSTimeInterval delayStop = (recordTime < kZZVideoRecorderMinimumRecordTime) ? kZZVideoRecorderMinimumRecordTime - recordTime : 0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayStop * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.recorder endVideoCapture];
        });
    });
}


#pragma mark - Cancel Recording

- (void)cancelRecording
{
    ANDispatchBlockToMainQueue(^{
        [self cancelRecordingWithReason:nil];
    });
}

- (void)cancelRecordingWithReason:(NSString*)reason
{
    if ([self isRecording])
    {
        if (!self.didCancelRecording)
        {
            self.didCancelRecording = YES;
            [self showCancelMessageWithReason:reason];
        }
        [self.recorder endVideoCapture];
    }
}


#pragma mark - Two Finger Touch

// TODO: Sani - These methods should be moved to GridPresenter

- (void)_startTouchObserve
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
        for (id event in touches)
        {
            NSSet* touches = [event allTouches];
            [self _handleTouches:touches];
        };
    }];
}

- (void)_handleTouches:(NSSet*)touches
{
    ANDispatchBlockToMainQueue(^{
        UITouch* touch = [[touches allObjects] firstObject];
        
        if ((touch.phase == UITouchPhaseBegan && [self isRecording]) ||
            (touch.phase == UITouchPhaseStationary && [self isRecording]))
        {
            //            CGFloat kDelayAfterTouch = 0.5;
            //            ANDispatchBlockAfter(kDelayAfterTouch, ^{
            [self _cancelRecordingWithDoubleTap];
            //            });
        }
        else if (touch.phase == UITouchPhaseEnded && [self isRecording])
        {
//            [self stopRecordingWithCompletionBlock:self.completionBlock];
        }
    });
}

- (void)_cancelRecordingWithDoubleTap
{
    [self cancelRecordingWithReason:NSLocalizedString(@"record-two-fingers-touch", nil)];
    ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
        [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
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

#pragma mark - UI messages
// TODO: Sani - These UI Methods should be moved to GridPresenter+UserDialogs

- (void)_showMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}

- (void)showVideoToShortToast
{
    [self _showMessage:NSLocalizedString(@"record-video-too-short", nil)];
    ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
        [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
}

- (void)showCancelMessageWithReason:(NSString *)reason{
    if (!ANIsEmpty(reason))
    {
        [self _showMessage:reason];
        ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
            [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
        });
    }
}

- (void)_showProbableOnCallAlert
{
    ZZLogInfo(@"alertProbablePhoneCall");
    if (self.onCallDialogShowing == YES)
    {
        return;
    }
    
    self.onCallDialogShowing = YES;
    NSString *msg = @"Mic or camera are busy. Are you on a phone call? Hangup and try again.";
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"On a Call?" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again"
                                               style:SDCAlertActionStyleDefault
                                             handler:^(SDCAlertAction *action) {
                                                 [self.recorder startPreview];
                                                 self.onCallDialogShowing = NO;
                                             }]];
    [alert presentWithCompletion:nil];
}

#pragma mark - Lifecycle observers
- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)_didBecomeActive
{
    ANDispatchBlockToMainQueue(^{
        [self.recorder startPreview];
    });
}

- (void)_willResignActive
{
    // We stop the preview so that TBMaudioSession can deactivate without error.
    ANDispatchBlockToMainQueue(^{
        [self.recorder stopPreview];
    });
}

#pragma mark - Sound effects
- (ZZSoundEffectPlayer*)soundPlayer
{
    if (!_soundPlayer)
    {
        _soundPlayer = [[ZZSoundEffectPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
    }
    return _soundPlayer;
}

#pragma mark - PBJVisionDelegate
// session

- (void)visionSessionWillStart:(PBJVision *)vision{}
- (void)visionSessionDidStart:(PBJVision *)vision{}
- (void)visionSessionDidStop:(PBJVision *)vision{}

- (void)visionSessionWasInterrupted:(PBJVision *)vision
{
    ZZLogInfo(@"visionSessionWasInterrupted");
    [self _showProbableOnCallAlert];
}
- (void)visionSessionInterruptionEnded:(PBJVision *)vision{}
- (BOOL)visionSessionRuntimeErrorShouldRetry:(PBJVision *)vision error:(NSError*)error
{
    if ([error code] == AVErrorDeviceIsNotAvailableInBackground ||
        [error code] == AVErrorDeviceIsNotAvailableInBackground)
    {
        return YES;
    }
    
    ZZLogInfo(@"visionSessionRuntimeErrored");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _showProbableOnCallAlert];
    });
    return NO;
}


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

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    ZZLogInfo(@"didStartVideoCapture");
    [[NSNotificationCenter defaultCenter] postNotificationName:kZZVideoRecorderDidStartVideoCapture
                                                        object:self
                                                      userInfo:@{@"videoUrl": self.recordVideoUrl}];

}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision{} // stopped but not ended
- (void)visionDidResumeVideoCapture:(PBJVision *)vision{}
- (void)visionDidEndVideoCapture:(PBJVision *)vision
{
    ZZLogInfo(@"didEndVideoCapture");
    [[NSNotificationCenter defaultCenter] postNotificationName:kZZVideoRecorderDidEndVideoCapture
                                                        object:self
                                                      userInfo:@{@"videoUrl": self.recordVideoUrl}];
    [self.soundPlayer play];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error{
    BOOL abort = NO;
    NSString *outputFilePath = videoDict[PBJVisionVideoPathKey];
    ZZLogInfo(@"didCaptureVideo");
    
    if (self.didCancelRecording)
    {
        ZZLogInfo(@"didCancelRecording");
        abort = YES;
    }
    else if (error)
    {
        NSError *newError = [NSError errorWithError:error reason:@"Problem recording video"];
        [self _handleError:newError];
        abort = YES;
    }
    else if (ANIsEmpty(outputFilePath))
    {
        NSError *error = [self _videoRecorderError:@"Nil outputFilePath" reason:@"Nil outputFilePath"];
        [self _handleError:error dispatch:YES];
        abort = YES;
    }
    else if ([self _videoTooShort:outputFilePath])
    {
        ZZLogInfo(@"videoTooShort aborting");
        NSError *error = [self _videoRecorderError:@"Video too short" reason:@"Too short"];
        [self _handleError:error dispatch:NO];
        [self showCancelMessageWithReason:NSLocalizedString(@"record-video-too-short", nil)];
        abort = YES;
    }
    
    if (!abort)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
        
        NSURL *outputFileURL = [NSURL fileURLWithPath:outputFilePath isDirectory:NO];
        NSError *copyError = nil;
        [[NSFileManager defaultManager] copyItemAtURL:outputFileURL toURL:self.recordVideoUrl error:&copyError];
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
            
        if (copyError)
        {
            [self _handleError:error dispatch:YES];
            abort = YES;
        }
    }
    
    if (abort)
    {
        if (!ANIsEmpty(outputFilePath))
        {
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        }
        [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
        [self _sendCompletionWithResult:NO];
        return;
    }

    
    ZZLogInfo(@"didFinishRecording success");
    [self _sendCompletionWithResult:YES];
    [[[TBMVideoProcessor alloc] init] processVideoWithUrl:self.recordVideoUrl];
}

// video capture progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{}
- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer{}


#pragma mark - Helper Methods

- (void)_sendCompletionWithResult:(BOOL)result
{
    if (self.completionBlock)
    {
        self.completionBlock(result);
    }
}

- (void)_handleError:(NSError *)error
{
    [self _handleError:error dispatch:YES];
}

- (void)_handleError:(NSError *)error dispatch:(BOOL)dispatch
{
    if (dispatch)
    {
        ZZLogError(@"VideoRecorder: %@", error);
    }
}

- (BOOL)_videoTooShort:(NSString *)videoPath
{
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&error];
    if (error != nil)
    {
        ZZLogError(@"VideoRecorder#videoTooShort: Can't set attributes for file: %@. Error: %@", videoPath, error);
        return NO;
    }
    
    ZZLogInfo(@"filesize %llu", fileAttributes.fileSize);
    if (fileAttributes.fileSize < 32000)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSError *)_videoRecorderError:(NSString *)description reason:(NSString *)reason
{
    return [NSError errorWithDomain:@"TBMVideoRecorder"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: description,
                                      NSLocalizedFailureReasonErrorKey: reason}];
}



@end

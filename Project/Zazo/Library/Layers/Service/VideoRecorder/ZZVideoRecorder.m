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
#import "TBMVideoIdUtils.h"
#import "ZZFriendDataProvider.h"

NSString* const kVideoProcessorDidFinishProcessing = @"kZZVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"kZZVideoProcessorDidFailProcessing";

NSString* const kZZVideoRecorderDidFinishRecording = @"kZZVideoRecorderDidFinishRecording";
NSString* const kZZVideoRecorderShouldStartRecording = @"kZZVideoRecorderShouldStartRecording";
NSString* const kZZVideoRecorderDidCancelRecording = @"kZZVideoRecorderDidCancelRecording";
NSString* const kZZVideoRecorderDidFail = @"kZZVideoRecorderDidFail";

static CGFloat const kDelayBeforeNextMessage = 1.1;

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

#pragma mark - Recording indication

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

#pragma mark - Start Recording

- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.completionBlock = completionBlock;
    
    //TODO: Sani remove flag for isRecorderActive and isRecordingInProgres and just use state from PBJ
    self.isRecorderActive = YES;
    self.isRecordingInProgress = YES;
    
    self.didCancelRecording = NO;
    [self _startTouchObserve];
    
    //TODO: Sani change the name of notification. Call it from PBJDelegate call.
    [[NSNotificationCenter defaultCenter] postNotificationName:kZZVideoRecorderShouldStartRecording object:self];
    self.recordVideoUrl = url;
    [self.recorder startVideoCapture];
}

#pragma mark - Stop Recording

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.isRecorderActive = NO;
    self.completionBlock = completionBlock;
    if ([self isRecording])
    {
        [self.recorder endVideoCapture];
    }
    [self _recordingProgressStopped];
}


// TODO: Sani - Remove this after I find out what the hack is for.
- (void)_recordingProgressStopped
{
    CGFloat kDelayAfterRecordingStopped = 0.5f;
    ANDispatchBlockAfter(kDelayAfterRecordingStopped, ^{
        self.isRecordingInProgress = NO;
    });
}


#pragma mark - Cancel Recording

- (void)cancelRecording
{
    ANDispatchBlockToMainQueue(^{
        [self cancelRecordingWithReason:nil];
    });
}

// TODO: Sani Try using cancelVideoCapture and getting rid of cancelFlag.
- (void)cancelRecordingWithReason:(NSString*)reason
{
    if (self.isRecorderActive)
    {
        if (!self.didCancelRecording)
        {
            [self _notifyCancelRecording];
            self.didCancelRecording = YES;
            if (!ANIsEmpty(reason))
            {
                [self _showMessage:reason];
                ANDispatchBlockAfter(kDelayBeforeNextMessage, ^{
                    [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
                });
            }
            [self.recorder endVideoCapture];
        }
    }
    self.isRecorderActive = NO;
    [self _recordingProgressStopped];
}

- (void)_notifyCancelRecording
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kZZVideoRecorderDidCancelRecording
                                                        object:self
                                                      userInfo:@{@"videoUrl": self.recordVideoUrl}];
}


#pragma mark - Two Finger Touch

// TODO: Sani - This should be moved to GridPresenter
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
        
        if ((touch.phase == UITouchPhaseBegan && self.isRecorderActive) ||
            (touch.phase == UITouchPhaseStationary && self.isRecorderActive))
        {
            //            CGFloat kDelayAfterTouch = 0.5;
            //            ANDispatchBlockAfter(kDelayAfterTouch, ^{
            [self _cancelRecordingWithDoubleTap];
            //            });
        }
        else if (touch.phase == UITouchPhaseEnded && self.isRecorderActive)
        {
            [self stopRecordingWithCompletionBlock:self.completionBlock];
        }
    });
}

- (void)_cancelRecordingWithDoubleTap
{
    [self cancelRecordingWithReason:NSLocalizedString(@"record-two-fingers-touch", nil)];
    ANDispatchBlockAfter(kDelayBeforeNextMessage, ^{
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

#pragma mark - Audio Session

// TODO: Sani - Find out why these are necessary and remove if not needed.
- (void)stopAudioSession
{
    //[self.recorder removeAudioInput];
}

- (void)startAudioSession
{
    //[self.recorder addAudioInput];
}


#pragma mark - UI messages

// TODO: Sani - This should be moved to GridPresenter+UserDialogs
- (void)_showMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}

- (void)showVideoToShoortToast
{
    [self _showMessage:NSLocalizedString(@"record-video-too-short", nil)];
    ANDispatchBlockAfter(kDelayBeforeNextMessage, ^{
        [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
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

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error{
    BOOL abort = NO;
    NSURL *outputFileURL = videoDict[PBJVisionVideoPathKey];
    
    if (self.didCancelRecording)
    {
        ZZLogInfo(@"didCancelRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);
        [self _sendCompletionWithResult:NO];
        abort = YES;
    }
    else if (error != nil)
    {
        NSError *newError = [NSError errorWithError:error reason:@"Problem recording video"];
        [self _handleError:newError];
        [self _sendCompletionWithResult:NO];
        abort = YES;
    }
    else if ([self _videoTooShort:outputFileURL])
    {
        ZZLogInfo(@"VideoRecorder#videoTooShort aborting");
        NSError *error = [self _videoRecorderError:@"Video too short" reason:@"Too short"];
        [self _handleError:error dispatch:NO];
        
        
        [self _sendCompletionWithResult:NO];
        
        if (self.didCancelRecording)
        {
            ANDispatchBlockAfter((kDelayBeforeNextMessage * 2), ^{
                [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
            });
        }
        else
        {
            [self _showMessage:NSLocalizedString(@"record-video-too-short", nil)];
            ANDispatchBlockAfter(kDelayBeforeNextMessage, ^{
                [self _showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
            });
        }
        abort = YES;
    }
    
    
    ZZFileTransferMarkerDomainModel* marker = [TBMVideoIdUtils markerModelWithOutgoingVideoURL:self.recordVideoUrl];
    TBMFriend *friend = [ZZFriendDataProvider friendEntityWithItemID:marker.friendID];
    
    [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
    
    NSError *copyError = nil;
    [[NSFileManager defaultManager] copyItemAtURL:outputFileURL toURL:self.recordVideoUrl error:&copyError];
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    if (copyError)
    {
        ZZLogError(@"copyError %@ - This should never happen", copyError);
        [self _handleError:error dispatch:YES];
        abort = YES;
    }
    
    if (abort)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
        return;
    }
    
    ZZLogInfo(@"didFinishRecording success friend:%@ videoId:%@", friend.firstName, marker.videoID);
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZZVideoRecorderDidFail
                                                        object:self
                                                      userInfo:@{@"error":error}];
}

- (BOOL)_videoTooShort:(NSURL *)videoUrl
{
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoUrl.path error:&error];
    if (error != nil)
    {
        ZZLogError(@"VideoRecorder#videoTooShort: Can't set attributes for file: %@. Error: %@", videoUrl.path, error);
        return NO;
    }
    
    ZZLogInfo(@"VideoRecorder: filesize %llu", fileAttributes.fileSize);
    if (fileAttributes.fileSize < 28000)
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

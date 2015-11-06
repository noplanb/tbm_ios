//
//  ZZVideoRecorder.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoRecorderDeprecated.h"
#import "ZZDeviceHandlerDeprecated.h"
#import "ZZGridCell.h"
#import "ZZGridDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoProcessor.h"
#import "ZZGridCellViewModel.h"
#import "ZZGridCenterCell.h"
#import "ZZGridUIConstants.h"
#import "TBMVideoProcessor.h"
#import "iToast.h"
#import "AVAudioSession+TBMAudioSession.h"
#import "TBMVideoRecorderDeprecated.h"
#import "TBMVideoIdUtils.h"
#import "NSError+ZZAdditions.h"
#import "ZZFriendDataProvider.h"

NSString* const kVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";
NSString* const TBMVideoRecorderDidCancelRecording = @"TBMVideoRecorderDidCancelRecording";
NSString* const TBMVideoRecorderDidFail = @"TBMVideoRecorderDidFail";

static CGFloat const kZZVideoRecorderDelayBeforeNextMessage = 1.1;

@interface ZZVideoRecorderDeprecated () <TBMAudioSessionDelegate, TBMVideoRecorderDelegate>

@property (nonatomic, strong) TBMVideoRecorderDeprecated *recorder;
@property (nonatomic, strong) NSURL* recordVideoUrl;
@property (nonatomic, strong) TBMVideoProcessor* videoProcessor;
@property (nonatomic, strong) NSMutableArray* delegatesArray;
@property (nonatomic, copy) void (^completionBlock)(BOOL isRecordingSuccess);
@property (nonatomic, strong) UIView* recordingView;

@end

@implementation ZZVideoRecorderDeprecated

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
        self.recorder = [[TBMVideoRecorderDeprecated alloc] init];
        self.recorder.delegate = self;
//        [self.recorder startRunning];
        
        self.delegatesArray = [NSMutableArray array];
        
        [[AVAudioSession sharedInstance] addTBMAudioSessionDelegate:self];
    }
    return self;
}

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

- (void)setRecordingView:(UIView *)recordingView
{
    _recordingView = recordingView;
    [self.recorder setupCaptureSessionView:_recordingView];
}

- (void)updateRecorder
{
    if (!self.recordingView)
    {
        // update reocroding view
        self.recordingView = [self.interfaceDelegate recordingView];
        [self updateRecordView:self.recordingView];
        
        // update recorder
        self.videoProcessor = [TBMVideoProcessor new];
        self.recorder.delegate = self;
        [self.recorder setupCaptureSessionView:self.recordingView];
        [self.recorder startRunning];
    }
    else
    {
        //update recorder session and audio input
        [self.recorder startRunning];
    }
    
    [self startAudioSession];
    
    // alert message after recording
    if (self.didCancelRecording)
    {
        self.didCancelRecording = NO;
        [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    }
}

//TODO: review this code, to handle all exising cases
////-----------------------------------
//// VideoRecorder setup and callbacks
////-----------------------------------
//- (void)videoRecorderDidStartRunning {
//}
//
//- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount {
//    ZZLogError(@"videoRecorderRuntimeErrorWithRetryCount %d", videoRecorderRetryCount);
//    [self setupVideoRecorder:videoRecorderRetryCount];
//}
//
//// We call setupVideoRecorder on multiple events so the first qualifying event takes effect. All later events are ignored.
//- (void)setupVideoRecorder:(int)retryCount {
//    // Note that when we get retryCount != 0 we are being called because of a videoRecorderRuntimeError and we need reinstantiate
//    // even if videoRecorder != nil
//    // Also if we still have a videoRecorder but the OS killed our view from under us trying to save memory while we were in the
//    // background we want to reinstantiate.
//    if (self.videoRecorder != nil && retryCount == 0 && [self isViewLoaded] && self.view.window) {
//        ZZLogWarning(@"TBMHomeViewController: setupVideoRecorder: already setup. Ignoring");
//    }
//    else if (![self appDelegate].isForeground) {
//        ZZLogWarning(@"HomeViewController: not initializing the VideoRecorder because ! isForeground");
//    }
//    else
//    {
//        ZZLogWarning(@"HomeviewController: setupVideoRecorder: setting up. vr=%@, rc=%d, isViewLoaded=%d, view.window=%d", self.videoRecorder, retryCount, [self isViewLoaded], [self isViewLoaded] && self.view.window);
//        
//        //        self.videoRecorder = [[TBMVideoRecorder alloc] initWithPreviewView:nil//[self centerView]
//        //                                                                  delegate:self];
//    }
//    [self.videoRecorder startRunning];
//}


//TODO:
- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount {
    ZZLogError(@"videoRecorderRuntimeErrorWithRetryCount %d", videoRecorderRetryCount);
    [self setupVideoRecorder:videoRecorderRetryCount];
}

// We call setupVideoRecorder on multiple events so the first qualifying event takes effect. All later events are ignored.
- (void)setupVideoRecorder:(int)retryCount
{
    self.recorder = [TBMVideoRecorderDeprecated new];
    self.recorder.delegate = self;
    
    if (!self.recordingView)
    {
        self.recordingView = [self.interfaceDelegate recordingView];
        [self updateRecordView:self.recordingView];
    }
    
    [self.recorder setupCaptureSessionView:self.recordingView];
    [self.recorder startRunning];
}


#pragma mark - TBMAudioDelegate

- (void)willDeactivateAudioSession
{
//    [self.recorder stopRunning]; //TODO:
    [self cancelRecording];
}

- (void)cancelRecording
{
    ANDispatchBlockToMainQueue(^{
        [self cancelRecordingWithReason:nil];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startTouchObserve
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
        for (id event in touches)
        {
            NSSet* touches = [event allTouches];
            [self handleTouches:touches];
        };
    }];
}

- (void)handleTouches:(NSSet*)touches
{
    ANDispatchBlockToMainQueue(^{
        UITouch* touch = [[touches allObjects] firstObject];
        
        if ((touch.phase == UITouchPhaseBegan && self.isRecorderActive) ||
            (touch.phase == UITouchPhaseStationary && self.isRecorderActive))
        {
//            CGFloat kDelayAfterTouch = 0.5;
//            ANDispatchBlockAfter(kDelayAfterTouch, ^{
                [self cancelRecordingWithDoubleTap];
//            });
        }
        else if (touch.phase == UITouchPhaseEnded && self.isRecorderActive)
        {
            [self stopRecordingWithCompletionBlock:self.completionBlock];
        }
    });
}

- (void)cancelRecordingWithDoubleTap
{
    [self cancelRecordingWithReason:NSLocalizedString(@"record-two-fingers-touch", nil)];
    ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
      [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
}

- (BOOL)areBothCamerasAvailable
{
    return [ZZDeviceHandlerDeprecated areBothCamerasAvailable];
}

- (void)switchCamera
{
    if ([self areBothCamerasAvailable])
    {
        BOOL isFrontCamera = (self.recorder.device == AVCaptureDevicePositionFront);
        if (isFrontCamera)
        {
            [self _switchToBackCamera];
        }
        else
        {
            [self _switchToFrontCamera];
        }
    }
}

- (void)_switchToBackCamera
{
    NSError *error;
    self.recorder.videoInput = [ZZDeviceHandlerDeprecated loadAvailableBackVideoInputWithError:&error];
    if (error)
    {
        // TODO:
    }
    [self.recorder.captureSession beginConfiguration];
    for (AVCaptureInput* input in self.recorder.captureSession.inputs)
    {
        [self.recorder.captureSession removeInput:input];
    }
    
    [self.recorder.captureSession addInput:self.recorder.videoInput];
    
    [self.recorder.captureSession commitConfiguration];
    [self _initAudioInput];
}

- (void)_switchToFrontCamera
{
    NSError *error;
    self.recorder.videoInput = [ZZDeviceHandlerDeprecated loadAvailableFrontVideoInputWithError:&error];
    if (error)
    {
        // TODO:
    }
    [self.recorder.captureSession beginConfiguration];
    for (AVCaptureInput* input in self.recorder.captureSession.inputs)
    {
        [self.recorder.captureSession removeInput:input];
    }
    
    [self.recorder.captureSession addInput:self.recorder.videoInput];
    
    [self.recorder.captureSession commitConfiguration];
    [self _initAudioInput];
}

- (void)_initAudioInput
{
    NSError *error;
    self.recorder.audioInput = [ZZDeviceHandlerDeprecated loadAudioInputWithError:&error];
    if (error)
    {
        //TODO:
    }
    [self.recorder.captureSession addInput:self.recorder.audioInput];
}


#pragma mark - Public Methods

- (void)updateRecordView:(UIView*)recordView
{
    if (recordView)
    {
        recordView.frame = CGRectMake(0, 0, kGridItemSize().width, kGridItemSize().height);
        [self.recorder setupCaptureSessionView:recordView];
    }
}

- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.completionBlock = completionBlock;
    self.isRecorderActive = YES;
    self.isRecordingInProgress = YES;
    
    self.didCancelRecording = NO;
    [self startTouchObserve];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    [self _startRecordingWithVideoUrl:url];
    [self.recorder startRecordingWithVideoUrl:url];
}


#pragma mark - Start Recording

- (void)_startRecordingWithVideoUrl:(NSURL *)videoUrl
{
    self.recordVideoUrl = videoUrl;
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
}


#pragma mark - Cancel Recording

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
                [self showMessage:reason];
                ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
                    [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
                });
            }
            [self.recorder cancelRecording];
        }
    }
    self.isRecorderActive = NO;
    [self _recordingProgressStopped];
}

- (void)_recordingProgressStopped
{
    CGFloat kDelayAfterRecordingStopped = 0.5f;
    ANDispatchBlockAfter(kDelayAfterRecordingStopped, ^{
        self.isRecordingInProgress = NO;
    });
}

#pragma mark - Stop Recording

- (void)stopAudioSession
{
    [self.recorder removeAudioInput];
}

- (void)startAudioSession
{
    [self.recorder addAudioInput];
}

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.isRecorderActive = NO;
    self.completionBlock = completionBlock;
    if ([self.recorder.captureOutput isRecording])
    {
        [self.recorder stopRecording];
    }
    [self _recordingProgressStopped];
}

- (void)videoRecorderDidStartRecording
{
    
}

- (void)videoRecorderDidStopRecording
{

}

- (void)videoRecorderDidStartRunning
{
    
}

- (void)videoRecorderDidStopButDidNotStartRecording
{
    NSString* details = @"VideoRecorder@stopRecording called but not recording. This should never happen";
    NSError* error = [self videoRecorderError:details reason:@"Problem recording video"];
    [self handleError:error];
}

- (void)videoRecorderDidFinishRecordingWithURL:(NSURL *)outputFileURL error:(NSError *)error
{
    BOOL abort = NO;
    
    if (self.didCancelRecording)
    {
        ZZLogInfo(@"didCancelRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidCancelRecording
                                                            object:self
                                                          userInfo:@{@"videoUrl": outputFileURL}];
        
        [self _recordingResultSuccess:NO];
  
        abort = YES;
    }
    else if (error != nil)
    {
        NSError *newError = [NSError errorWithError:error reason:@"Problem recording video"];
        [self handleError:newError];
         [self _recordingResultSuccess:NO];
        abort = YES;
    }
    else if ([self videoTooShort:outputFileURL])
    {
        ZZLogInfo(@"VideoRecorder#videoTooShort aborting");
        NSError *error = [self videoRecorderError:@"Video too short" reason:@"Too short"];
        [self handleError:error dispatch:NO];
        
        
        [self _recordingResultSuccess:NO];
        
        if (self.didCancelRecording)
        {
            ANDispatchBlockAfter((kZZVideoRecorderDelayBeforeNextMessage * 2), ^{
                [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
            });
        }
        else
        {
            [self showMessage:NSLocalizedString(@"record-video-too-short", nil)];
            ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
                [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
            });
        }
        abort = YES;
    }
    
    if (abort)
    {
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        return;
    }
    
    ZZFileTransferMarkerDomainModel* marker = [TBMVideoIdUtils markerModelWithOutgoingVideoURL:outputFileURL];
    TBMFriend *friend = [ZZFriendDataProvider friendEntityWithItemID:marker.friendID];
    
    ZZLogInfo(@"didFinishRecording success friend:%@ videoId:%@", friend.firstName, marker.videoID);
    
    [self _recordingResultSuccess:YES];
    
    [[[TBMVideoProcessor alloc] init] processVideoWithUrl:outputFileURL];
}




#pragma mark - Recording Error Handling.

- (void)handleError:(NSError *)error
{
    [self handleError:error dispatch:YES];
}

- (void)handleError:(NSError *)error dispatch:(BOOL)dispatch
{
    if (dispatch)
    {
        ZZLogError(@"VideoRecorder: %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFail
                                                        object:self
                                                      userInfo:@{@"error":error}];
}

- (void)videoRecordDidFailNotification:(NSNotification *)notification
{
    NSError *error = (NSError *) notification.userInfo[@"error"];
    NSString *reason = error.userInfo[NSLocalizedFailureReasonErrorKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reason != nil)
            [[iToast makeText:reason] show];
        
                [self performSelector:@selector(toastNotSent) withObject:nil afterDelay:1.2];
    });
}

//TODO:
- (void)toastNotSent
{
    [[iToast makeText:@"Not sent"] show];
}


//
//- (void)recorder:(SCRecorder*)recorder didCompleteSegment:(SCRecordSessionSegment*)segment
//       inSession:(SCRecordSession*)recordSession error:(NSError*)error
//{
//    if (error)
//    {
//        [self showMessage:NSLocalizedString(@"record-problem-recording", nil)];
//    }
//    else
//    {
//        [self recordVideoToFileWithRecordSession:recordSession];
//    }
//}

//- (void)recordVideoToFileWithRecordSession:(SCRecordSession*)recordSession
//{
//    
//    [recordSession mergeSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:^(NSURL *url, NSError *error) {
//        if (error == nil)
//        {
//            if ([self isVideoShort:url])
//            {
//                [self _recordingResultSuccess:NO];
//
//                if (self.didCancelRecording)
//                {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kDelayBeforeNextMessage * 2)  * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self showMessage:NSLocalizedString(@"record-video-too-short", nil)];
//                    });
//                }
//                else
//                {
//                    [self showMessage:NSLocalizedString(@"record-video-too-short", nil)];
//                }
//                
//                [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
//            }
//            else if (self.didCancelRecording)
//            {
//                [self _recordingResultSuccess:NO];
//                [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
//                
//            }
//            else
//            {
//                if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
//                {
//                    NSError* error;
//                    if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:self.recordVideoUrl error:&error])
//                    {
//                        NSError* removeError;
//                        [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&removeError];
//                        [self.videoProcessor processVideoWithUrl:self.recordVideoUrl];
//                        [self _recordingResultSuccess:YES];
//                    }
//                    else
//                    {
//                        NSLog(@"copy error");
//                        [self _recordingResultSuccess:NO];
//                    }
//                }
//                else
//                {
//                    NSLog(@"wrong");
//                    [self _recordingResultSuccess:NO];
//                }
//            }
//        } else {
//            
//        }
//    }];
//}

- (void)_recordingResultSuccess:(BOOL)result
{
    if (self.completionBlock)
    {
        self.completionBlock(result);
    }
}

//- (void)handleError:(NSError*)error dispatch:(BOOL)dispatch
//{
//    [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFail
//                                                        object:self
//                                                      userInfo:[self notificationUserInfoWithError:error]];
//}
//
//- (NSDictionary*)notificationUserInfoWithError:(NSError *)error
//{
//    if (error == nil)
//    {
//        return @{@"videoUrl" : self.recordVideoUrl};
//    }
//    else
//    {
//        return @{@"videoUrl" : self.recordVideoUrl, @"error": error};
//    }
//}

- (void)showMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}


- (void)showVideoToShoortToast
{
    [self showMessage:NSLocalizedString(@"record-video-too-short", nil)];
    ANDispatchBlockAfter(kZZVideoRecorderDelayBeforeNextMessage, ^{
        [self showMessage:NSLocalizedString(@"record-canceled-not-sent", nil)];
    });
}

#pragma mark Util

- (BOOL)videoTooShort:(NSURL *)videoUrl
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

- (NSError *)videoRecorderError:(NSString *)description reason:(NSString *)reason
{
    return [NSError errorWithDomain:@"TBMVideoRecorder"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: description,
                                      NSLocalizedFailureReasonErrorKey: reason}];
}





#pragma mark - Video Recorder Observer Methods

- (void)addDelegate:(id<ZZVideoRecorderDelegate>)delegate
{
    [self.delegatesArray addObject:delegate];
}

- (void)removeDelegate:(id<ZZVideoRecorderDelegate>)delegate
{
    [self.delegatesArray removeObject:delegate];
}

- (void)_notifyCancelRecording
{
    [self.delegatesArray enumerateObjectsUsingBlock:^(id<ZZVideoRecorderDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate videoRecordingCanceled];
    }];
}

@end

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
#import "iToast.h"
#import "ZZFeatureObserver.h"

NSString* const kVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
NSString* const kVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";
NSString* const TBMVideoRecorderDidCancelRecording = @"TBMVideoRecorderDidCancelRecording";
NSString* const TBMVideoRecorderDidFail = @"TBMVideoRecorderDidFail";
//NSString* const kZZVideoProcessorErrorReason = @"Problem processing video";

@interface ZZVideoRecorder () <SCRecorderDelegate>

@property (nonatomic, strong) SCRecorder *recorder;
@property (nonatomic, strong) NSURL* recordVideoUrl;
@property (nonatomic, strong) TBMVideoProcessor* videoProcessor;
@property (nonatomic, strong) NSMutableArray* delegatesArray;
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
        self.recorder = [SCRecorder recorder];
        // Start running the flow of buffers
        if (![self.recorder startRunning])
        {
            NSLog(@"Something wrong there: %@", self.recorder.error);
        }
        self.recorder.delegate = self;
        self.recorder.captureSessionPreset = AVCaptureSessionPresetLow;
        
        SCAudioConfiguration *audio = self.recorder.audioConfiguration;
        audio.enabled = YES;
        
        SCVideoConfiguration *video = self.recorder.videoConfiguration;
        video.enabled = YES;
        video.scalingMode = AVVideoScalingModeResizeAspectFill;
        
        self.recorder.device = AVCaptureDevicePositionFront;
        self.recorder.session = [SCRecordSession recordSession];
        self.delegatesArray = [NSMutableArray array];
        [self.recorder startRunning];
    }
    return self;
}

- (void)cancelRecording
{
    ANDispatchBlockToMainQueue(^{
        [self cancelRecordingWithReason:nil];
    });
}

- (void)updateRecorder
{
    if (!self.recorder)
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
    else
    {
        [self.recorder startRunning];
    }

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
    if ([[touches allObjects] count] > 1)
    {
        [self cancelRecordingWithReason:NSLocalizedString(@"record-two-fingers-touch", nil)];
        [[[iToast makeText:NSLocalizedString(@"record-canceled-not-sent", nil)] setGravity:iToastGravityCenter
                                                                                offsetLeft:0 offsetTop:60] show];
    }
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
    self.didCancelRecording = NO;
    [self startTouchObserve];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    [self _startRecordingWithVideoUrl:url];
    [self.recorder.session removeAllSegments];
    [self.recorder record];
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
    if (!self.didCancelRecording)
    {
        self.didCancelRecording = YES;
        if (!ANIsEmpty(reason))
        {
            [self showMessage:reason];
        }
        [self.recorder pause];
        [self _notifyCancelRecording];
    }
}

#pragma mark - Stop Recording

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    self.completionBlock = completionBlock;
    [self.recorder pause];
}

- (void)recorder:(SCRecorder*)recorder didCompleteSegment:(SCRecordSessionSegment*)segment
       inSession:(SCRecordSession*)recordSession error:(NSError*)error
{
    if (error)
    {
        [self showMessage:NSLocalizedString(@"record-problem-recording", nil)];
    }
    else
    {
        [self recordVideoToFileWithRecordSession:recordSession];
    }
}

- (void)recordVideoToFileWithRecordSession:(SCRecordSession*)recordSession
{
    
    [recordSession mergeSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:^(NSURL *url, NSError *error) {
        if (error == nil)
        {
            
            if ([self isVideoShort:url])
            {
                [self showMessage:NSLocalizedString(@"record-video-too-short", nil)];
                [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
                [self _recordingResultSuccess:NO];
            }
            else if (self.didCancelRecording)
            {
                [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
                [self _recordingResultSuccess:NO];
            }
            else
            {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
                {
                    NSError* error;
                    if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:self.recordVideoUrl error:&error])
                    {
                        NSError* removeError;
                        [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&removeError];
                        [self.videoProcessor processVideoWithUrl:self.recordVideoUrl];
                        [self _recordingResultSuccess:YES];
                    }
                    else
                    {
                        NSLog(@"copy error");
                        [self _recordingResultSuccess:NO];
                    }
                }
                else
                {
                    NSLog(@"wrong");
                    [self _recordingResultSuccess:NO];
                }
            }
        } else {
            
        }
    }];
}

- (void)_recordingResultSuccess:(BOOL)result
{
    if (self.completionBlock)
    {
        self.completionBlock(result);
    }
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

- (BOOL)isVideoShort:(NSURL *)videoUrl{
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoUrl.path error:&error];
    if (error != nil){
        OB_ERROR(@"VideoRecorder#videoTooShort: Can't set attributes for file: %@. Error: %@", videoUrl.path, error);
        return NO;
    }
    OB_INFO(@"VideoRecorder: filesize %llu", fileAttributes.fileSize);
    if (fileAttributes.fileSize < 28000){
        return YES;
    } else {
        return NO;
    }
}

- (void)showMessage:(NSString*)message
{
    [[iToast makeText:message] show];
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

//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMDeviceHandler.h"
#import "TBMConfig.h"
#import "OBLogger.h"
#import "TBMAlertController.h"
#import "TBMVideoProcessor.h"
#import "HexColor.h"
#import "TBMVideoIdUtils.h"

NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";
NSString* const TBMVideoRecorderDidCancelRecording = @"TBMVideoRecorderDidCancelRecording";

static int videoRecorderRetryCount = 0;

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) dispatch_queue_t sessionQueue;
@property TBMPreviewView *previewView;
@property AVCaptureSession *captureSession;
@property AVCaptureInput *videoInput;
@property AVCaptureInput *audioInput;
@property AVCaptureMovieFileOutput *captureOutput;

@property BOOL didCancelRecording;

@end

@implementation TBMVideoRecorder


- (instancetype)initWithPreviewView:(TBMPreviewView *)previewView delegate:(id)delegate {

    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        self.previewView = previewView;
        
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        
#warning Kirill Temporarily removed from background thread while testing.
        [self initCaptureSession];
        [self setupPreviewView];
        [self initVideoInput];
        [self initCaptureOutput];
        [self addAudioInput];
        [self addObservers];
        [self.captureSession startRunning];

//        dispatch_async(self.sessionQueue, ^{
//        });
    }
    return self;
}

#pragma mark - intialization of Video, Audio and Capture

- (void) initVideoInput {
    NSError *error;
    self.videoInput = [TBMDeviceHandler getAvailableFrontVideoInputWithError:&error];
    if (error) {
        OB_ERROR(@"VideoRecorder: Unable to getVideoCaptureInput (%@)", error);
    } else {
        [self.captureSession addInput:self.videoInput];
    }
}

- (void) initCaptureOutput {

    self.captureOutput = [[AVCaptureMovieFileOutput alloc] init];
   
    //We don't care about ability of adding output, because we do initialization of capture session for one time.
    //http://stackoverflow.com/questions/24501561/avcapturesession-canaddoutputoutput-returns-no-intermittently-can-i-find-o
    
    if ([self.captureSession canAddOutput:self.captureOutput]) {
        [self.captureSession addOutput:self.captureOutput];
    } else {
        OB_ERROR(@"VideoRecorder: addCaptureOutputWithError: Could not add captureOutput");
    }
}

- (void)initCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
    } else {
        OB_ERROR(@"Cannot set AVCaptureSessionPresetLow");
    }
}

- (void) addAudioInput {
    NSError *error;
    self.audioInput = [TBMDeviceHandler getAudioInputWithError:&error];
    
    if (error) {
        OB_ERROR(@"VideoRecorder: Unable to getAudioCaptureInput (Error: %@)", error);
        return;
    }
    
    [self.captureSession addInput:self.audioInput];
}

- (void) removeAudioInput {
    if (self.audioInput) {
        [self.captureSession removeInput:self.audioInput];
    }
}

#pragma mark - Query Status

- (BOOL)isRecording{
    return [self.captureOutput isRecording];
}


#pragma mark - Preview

- (void) setupPreviewView {
    [self.previewView setupWithCaptureSession:self.captureSession];
}


#pragma mark - Recording Actions

- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    
#warning Kirill I set this once in setup as it was causing record to flash and spurious errors. We should always use built in mic. Can we make sure that we always return built in mic from TBMDevicehandler.
//    [self addAsudioInput];
    self.didCancelRecording = NO;
    
    OB_INFO(@"Start recording to %@ videoId:%@",
            [TBMVideoIdUtils friendWithOutgoingVideoUrl:videoUrl].firstName,
            [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:videoUrl]);
    
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
        
    [self.previewView showRecordingOverlay];
    [self.captureOutput startRecordingToOutputFileURL:videoUrl recordingDelegate:self];
}

- (void)stopRecording {
    OB_INFO(@"stopRecording: isRecording:%d", self.captureOutput.isRecording);
    if (self.captureOutput.isRecording)
        [self.captureOutput stopRecording];

    [self.previewView hideRecordingOverlay];
}

- (BOOL)cancelRecording{
    self.didCancelRecording = YES;
    BOOL wasRecording = [self.captureOutput isRecording];
    [self stopRecording];
    return wasRecording;
}


#pragma mark - Recording callback

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections error:(NSError *)error{
    
#warning Kirill I set this once in setup as it was causing record to flash and spurious errors. We should always use built in mic. Can we make sure that we always return built in mic from TBMDevicehandler.
    //[self removeAudioInput];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFinishRecording
                                                        object:self
                                                      userInfo:@{@"videoUrl": outputFileURL}];
    
    if (self.didCancelRecording){
        OB_INFO(@"didCancelRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidCancelRecording
                                                            object:self
                                                          userInfo:@{@"videoUrl": outputFileURL}];
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        return;
    }
    
    OB_INFO(@"didFinishRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);

    [[[TBMVideoProcessor alloc] init] processVideoWithUrl:outputFileURL];
}



#pragma mark - Recording Session Notifications

// Dispose is not used. User should just create a new instance.
// Dont use dispose becuase OS takes care of interrupting or stopping and restarting our VideoCaptureSession very well.
// We don't need to interfere with it. See release 1.41 for details.
- (void)dispose{
    dispatch_sync(self.sessionQueue, ^{
        [self removeObservers];
        [self setDelegate:nil];
        [self.captureSession stopRunning];
    });
}

- (void)addObservers {
    OB_INFO(@"videoRecorder: addObservers");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionDidStartRunningNotification:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionDidStopRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
}

- (void) AVCaptureSessionRuntimeErrorNotification:(NSNotification *)notification{
    OB_INFO(@"AVCaptureSessionRuntimeErrorNotification");
    videoRecorderRetryCount += 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate videoRecorderRuntimeErrorWithRetryCount:videoRecorderRetryCount];
    });
}
- (void) AVCaptureSessionDidStartRunningNotification:(NSNotification *)notification{
    OB_INFO(@"AVCaptureSessionDidStartRunningNotification");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate videoRecorderDidStartRunning];
    });
}
- (void) AVCaptureSessionDidStopRunningNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionDidStopRunningNotification");
}
- (void) AVCaptureSessionWasInterruptedNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionWasInterruptedNotification");
}
- (void) AVCaptureSessionInterruptionEndedNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionInterruptionEndedNotification");
}


@end

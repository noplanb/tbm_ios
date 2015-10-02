//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMDeviceHandler.h"
#import "OBLogger.h"
#import "TBMAlertController.h"
#import "TBMVideoProcessor.h"
#import "TBMVideoIdUtils.h"
#import "NSError+Extensions.h"
#import "iToast.h"
#import "ZZVideoRecorder.h" // TODO: for constants

//NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
//NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";
//NSString* const TBMVideoRecorderDidCancelRecording = @"TBMVideoRecorderDidCancelRecording";
//NSString* const TBMVideoRecorderDidFail = @"TBMVideoRecorderDidFail";

static int videoRecorderRetryCount = 0;

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, assign) BOOL didCancelRecording;

@end

@implementation TBMVideoRecorder

@dynamic device;


#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[AVAudioSession sharedInstance] addTBMAudioSessionDelegate:self];
        
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        
        [self initCaptureSession];
        
        dispatch_async(self.sessionQueue, ^{
            [self initVideoInput];
            [self addAudioInput];
            [self initCaptureOutput];
            [self addObservers];
            [self.captureSession setUsesApplicationAudioSession:YES];
            [self.captureSession setAutomaticallyConfiguresApplicationAudioSession:NO];
            [self.captureSession startRunning];
        });
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}


#pragma mark - Getters / Setters

- (AVCaptureDevicePosition)device
{
    return [self _currentCamera];
}

- (void)setDevice:(AVCaptureDevicePosition)device
{
    [self switchCameraTo:device];
}

- (void)startRunning
{
    dispatch_async(self.sessionQueue, ^{
        if (self.captureSession != nil) [self.captureSession startRunning];
    });
}

- (void)switchCameraTo:(AVCaptureDevicePosition)device
{
    //Change camera source
    if (self.captureSession)
    {
        //Indicate that some changes will be made to the session
        [self.captureSession beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [self.captureSession.inputs objectAtIndex:0];
        [self.captureSession removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if (((AVCaptureDeviceInput*)currentCameraInput).device.position != device)
        {
            newCamera = [self _cameraWithPosition:device];
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [self.captureSession addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [self.captureSession commitConfiguration];
    }
}

- (AVCaptureDevice*)_cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (AVCaptureDevicePosition)_currentCamera
{
    AVCaptureInput* currentCameraInput = [self.captureSession.inputs objectAtIndex:0];
    return ((AVCaptureDeviceInput*)currentCameraInput).device.position;
}


#pragma mark - intialization of Video, Audio and Capture

- (void)initVideoInput
{
    NSError *error;
    self.videoInput = [TBMDeviceHandler getAvailableFrontVideoInputWithError:&error];
    if (error)
    {
        OB_ERROR(@"VideoRecorder#initVideoInput: Unable to get camera (%@)", error);
    }
    else
    {
        [self.captureSession addInput:self.videoInput];
    }
}

- (void)initCaptureOutput
{
    self.captureOutput = [[AVCaptureMovieFileOutput alloc] init];
    OB_INFO(@"VideoRecorder:maxRecordedDuration: %lld", self.captureOutput.maxRecordedDuration.value);
    OB_INFO(@"VideoRecorder:maxRecordedFileSize: %lld", self.captureOutput.maxRecordedFileSize);
    OB_INFO(@"VideoRecorder:minFreeDiskSpaceLimit: %lld", self.captureOutput.minFreeDiskSpaceLimit);
    
    if ([self.captureSession canAddOutput:self.captureOutput])
    {
        [self.captureSession addOutput:self.captureOutput];
    }
    else
    {
        OB_ERROR(@"VideoRecorder#addCaptureOutputWithError: Could not add captureOutput");
    }
}

- (void)initCaptureSession
{
    self.captureSession = [AVCaptureSession new];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow])
    {
        self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
    }
    else
    {
        OB_ERROR(@"VideoRecorder#initCaptureSession: Cannot set AVCaptureSessionPresetLow");
    }
}

- (void)addAudioInput
{
    
//    if (!self.audioInput)
//    {
        NSError *error;
        self.audioInput = [TBMDeviceHandler getAudioInputWithError:&error];
        if (error)
        {
            OB_ERROR(@"VideoRecorder#addAudioInput Unable to get microphone: %@", error);
            return;
        }
        
        [self.captureSession addInput:self.audioInput];
//    }
//    else
//    {
//        [self.captureSession removeInput:self.audioInput];
//        [self.captureSession addInput:self.audioInput];
//    }
}

- (void)removeAudioInput
{
    if (self.audioInput)
    {
        [self.captureSession removeInput:self.audioInput];
    }
}


#pragma mark - Query Status

- (BOOL)isRecording
{
    return [self.captureSession isRunning];
}


#pragma mark - Preview

- (void)setupCaptureSessionView:(UIView *)view
{
    OB_DEBUG(@"VideoRecorder:setupPreviewView:");
    
    view.layer.sublayers = nil;
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = view.layer.bounds;
    [view.layer addSublayer:previewLayer];
}


#pragma mark - Recording Actions

- (void)startRecordingWithVideoUrl:(NSURL*)videoUrl
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    self.didCancelRecording = NO;
    
    OB_INFO(@"Start recording to %@ videoId:%@",
            [TBMVideoIdUtils friendWithOutgoingVideoUrl:videoUrl].firstName,
            [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:videoUrl]);
    
    
    [self.delegate videoRecorderDidStartRecording];
    [self.captureOutput startRecordingToOutputFileURL:videoUrl recordingDelegate:self];
}

- (void)stopRecording
{
    OB_INFO(@"VideoRecorder#stopRecording: isRecording:%d", self.captureOutput.isRecording);
    
    if (!self.captureOutput.isRecording)
    {
        // note that in some error cases when audiosession was connected stop recording would be called and isRecording == NO.  We will not get a didFinsishRecording in this case. AudioSession needs to observe videoRecorderDidFail for these condtitions although we should ensure they never occur.
        
        [self.delegate videoRecorderDidStopButDidNotStartRecording];
    }
    [self.captureOutput stopRecording];
    [self.delegate videoRecorderDidStopRecording];
}

- (BOOL)cancelRecording
{
    self.didCancelRecording = YES;
    BOOL wasRecording = [self.captureOutput isRecording];
    [self stopRecording];
    return wasRecording;
}


#pragma mark - Recording callback

- (void)captureOutput:(AVCaptureFileOutput*)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL*)fileURL
      fromConnections:(NSArray*)connections
{
    OB_INFO(@"VideoRecoder: captureOutput:didStartRecording");
    OB_INFO(@"captureOutput:didStartRecording %@", connections);
}

- (void)captureOutput:(AVCaptureFileOutput*)captureOutput
willFinishRecordingToOutputFileAtURL:(NSURL*)outputFileURL
      fromConnections:(NSArray*)connections
                error:(NSError*)error
{
    OB_INFO(@"willFinishRecordingToOutputFileAtURL %@", error);
    OB_INFO(@"willFinishRecordingToOutputFileAtURL %@", connections);
}

- (void)captureOutput:(AVCaptureFileOutput*)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error{
    OB_INFO(@"didFinishRecordingToOutputFileAtURL %@", error);
    OB_INFO(@"didFinishRecordingToOutputFileAtURL %@", connections);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFinishRecording
                                                        object:self
                                                      userInfo:@{@"videoUrl": outputFileURL}];
    
    [self.delegate videoRecorderDidFinishRecordingWithURL:outputFileURL error:error];
}



#pragma mark - Recording Session Notifications

- (void)addObservers
{
    OB_INFO(@"videoRecorder: addObservers");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AVCaptureSessionRuntimeErrorNotification:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:_captureSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AVCaptureSessionDidStartRunningNotification:)
                                                 name:AVCaptureSessionDidStartRunningNotification
                                               object:_captureSession];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)AVCaptureSessionRuntimeErrorNotification:(NSNotification *)notification
{
    OB_INFO(@"AVCaptureSessionRuntimeErrorNotification: %@", notification.userInfo[AVCaptureSessionErrorKey]);
    videoRecorderRetryCount += 1;
    if (videoRecorderRetryCount < 5)
    {
        [self.delegate videoRecorderRuntimeErrorWithRetryCount:videoRecorderRetryCount];
    }
}
- (void)AVCaptureSessionDidStartRunningNotification:(NSNotification *)notification
{
    OB_INFO(@"AVCaptureSessionDidStartRunningNotification");
    [self.delegate videoRecorderDidStartRunning];
}


#pragma mark AudioSessionDelegate

- (void)willDeactivateAudioSession
{
    OB_INFO(@"VideoRecorder: willDeactivateAudioSession");
    [self.captureSession stopRunning];
}

@end

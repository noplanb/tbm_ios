//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMDeviceHandler.h"
#import "TBMSoundEffect.h"
#import "TBMConfig.h"
#import "OBLogger.h"
#import "TBMAlertController.h"
#import "HexColor.h"

NSString* const TBMVideoRecorderDidFinishRecording = @"TBMVideoRecorderDidFinishRecording";
NSString* const TBMVideoRecorderShouldStartRecording = @"TBMVideoRecorderShouldStartRecording";

static int videoRecorderRetryCount = 0;

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) dispatch_queue_t sessionQueue;
@property TBMPreviewView *previewView;
@property AVCaptureSession *captureSession;
@property AVCaptureInput *videoInput;
@property AVCaptureInput *audioInput;
@property AVCaptureMovieFileOutput *captureOutput;
@property NSFileManager *fileManager;
@property NSURL *recordingVideoUrl;
@property NSURL *recordedVideoMpeg4Url;


@property NSString *marker;
@property BOOL didCancelRecording;

@end

@implementation TBMVideoRecorder

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker {
    NSString *filename = [NSString stringWithFormat:@"outgoingVidToFriend%@", marker];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

- (instancetype)initWithPreviewView:(TBMPreviewView *)previewView delegate:(id)delegate {

    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        self.previewView = previewView;
        
        self.fileManager = [NSFileManager defaultManager];
        
        self.recordingVideoUrl = [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[@"new" stringByAppendingPathExtension:@"mov"]];
        self.recordedVideoMpeg4Url = [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[@"newConverted" stringByAppendingPathExtension:@"mp4"]];
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        
        [self initCaptureSession];
        [self setupPreviewView];
        
        dispatch_async(self.sessionQueue, ^{
            [self initVideoInput];
            [self initCaptureOutput];
            [self addObservers];
            [self.captureSession startRunning];
        });
    }
    return self;
}

#pragma mark - intiialization of Video, Audio and Capture

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

#pragma mark -

//-------------
// Query status
//-------------

- (BOOL)isRecording{
    return [self.captureOutput isRecording];
}

//-------------------
// Handle previewView
//-------------------

- (void) setupPreviewView {
    [self.previewView setupWithCaptureSession:self.captureSession];
}

//------------------
// Recording actions
//------------------
- (void)startRecordingWithMarker:(NSString *)marker{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderShouldStartRecording object:self];
    
    [self addAudioInput];
    self.didCancelRecording = NO;
    
    self.marker = marker;
    OB_INFO(@"Started recording with marker %@", _marker);
    
    NSError *error = nil;
    [self.fileManager removeItemAtURL:self.recordingVideoUrl error:&error];
        
    [self.previewView showRecordingOverlay];
    [self.captureOutput startRecordingToOutputFileURL:self.recordingVideoUrl recordingDelegate:self];
}

- (void)stopRecording {
    if ([self.captureOutput isRecording])
        [self.captureOutput stopRecording];

    [self.previewView hideRecordingOverlay];
}

- (BOOL)cancelRecording{
    self.didCancelRecording = YES;
    BOOL wasRecording = [self.captureOutput isRecording];
    [self stopRecording];
    return wasRecording;
}

//------------------------------------------------
// Recording Finished callback and post processing
//------------------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    OB_INFO(@"didFinishRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);
    
    [self removeAudioInput];
    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFinishRecording object:self];
    
    if (self.didCancelRecording)
        return;
    
    if (error){
        OB_ERROR(@"%@", error);
        return;
    }
    
    NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:[self.recordingVideoUrl path] error:&error];
    OB_INFO(@"Recorded file size = %llu", fileAttributes.fileSize);
    [self convertOutgoingFileToMpeg4];
}

- (void)convertOutgoingFileToMpeg4 {
    NSError *dontCareError = nil;
    [self.fileManager removeItemAtURL:self.recordedVideoMpeg4Url error:&dontCareError];
    
    AVAsset *asset = [AVAsset assetWithURL:self.recordingVideoUrl];
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    session.outputFileType = AVFileTypeMPEG4;
    session.outputURL = self.recordedVideoMpeg4Url;
    [session exportAsynchronouslyWithCompletionHandler:^{[self didFinishConvertingToMpeg4];}];
}

- (void)didFinishConvertingToMpeg4 {
    if ([self moveRecordingToOutgoingFile]) {
        [self.delegate didFinishVideoRecordingWithMarker:self.marker];
    }
}

- (BOOL) moveRecordingToOutgoingFile {
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithMarker:self.marker];
    NSError *dontCareError = nil;
    
    [self.fileManager removeItemAtURL:outgoingVideoUrl error:&dontCareError];
    if (dontCareError)
        OB_WARN(@"Can't remove video (%@) for url (%@), error: %@", self.marker, outgoingVideoUrl, dontCareError);
    
    NSError *error = nil;
    [self.fileManager moveItemAtURL:self.recordedVideoMpeg4Url toURL:outgoingVideoUrl error:&error];
    
    if (error) {
        OB_ERROR(@"ERROR: moveRecordingToOutgoingFile: ERROR: unable to move file. This should never happen. %@", error);
        return NO;
    }
    
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:outgoingVideoUrl.path error:&dontCareError];
    if (dontCareError)
        OB_WARN(@"Can't set attributes for file: %@. Error: %@", outgoingVideoUrl.path, dontCareError);
        
    OB_INFO(@"moveRecordingToOutgoingFile: Outgoing file size %llu", fileAttributes.fileSize);
    return YES;
}


//-------------------------------
// AVCaptureSession Notifications
//-------------------------------
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

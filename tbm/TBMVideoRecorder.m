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

static int videoRecorderRetryCount = 0;

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>
@property (nonatomic) dispatch_queue_t sessionQueue;
@property UIView *previewView;
@property AVCaptureSession *captureSession;
@property AVAudioSession *audioSession;
@property AVCaptureInput *videoInput;
@property AVCaptureInput *audioInput;
@property NSFileManager *fileManager;
@property AVCaptureMovieFileOutput *captureOutput;
@property NSURL *videosDirectoryUrl;
@property NSURL *recordingVideoUrl;
@property NSURL *recordedVideoMpeg4Url;
@property CALayer *recordingOverlay;
@property TBMSoundEffect *dingSoundEffect;
@property NSString *marker;
@property BOOL didCancelRecording;
@property UILabel *recordingLabel;
@end

@implementation TBMVideoRecorder

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker{
    NSString *filename = [NSString stringWithFormat:@"outgoingVidToFriend%@", marker];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

// GARF: since videoRecorder does most of its init on another async thread it really doesnt make sense to pass error to it
// but leave it this way for now as the caller really doesnt do anything with the error.
- (instancetype)initWithPreviewView:(UIView *)previewView delegate:(id)delegate error:(NSError * __autoreleasing *)error{
    self = [super init];
    if (self){
        _delegate = delegate;
        _previewView = previewView;
        _fileManager = [NSFileManager defaultManager];
        _videosDirectoryUrl = [TBMConfig videosDirectoryUrl];
        _recordingVideoUrl = [_videosDirectoryUrl URLByAppendingPathComponent:[@"new" stringByAppendingPathExtension:@"mov"]];
        _recordedVideoMpeg4Url = [_videosDirectoryUrl URLByAppendingPathComponent:[@"newConverted" stringByAppendingPathExtension:@"mp4"]];
        _dingSoundEffect = [[TBMSoundEffect alloc] initWithSoundNamed:CONFIG_DING_SOUND];
        _sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        
        if (![self setupSessionWithError:&*error]){
            OB_ERROR(@"VideoRecorder: Unable to setup AVCaptureSession");
            return nil;
        }
        OB_INFO(@"Set up session: %@", _captureSession);

        [self setupPreviewView];
        
        dispatch_async(_sessionQueue, ^{
            __block NSError *blockError;
            //
            // Video
            //
            if (![self getVideoCaptureInputWithError:&blockError]){
                OB_ERROR(@"VideoRecorder: Unable to getVideoCaptureInput");
                return;
            }

            [_captureSession addInput:_videoInput];
            OB_INFO(@"Added videoInput: %@", _videoInput);
            
            //
            // Audio
            //
            [self setupAudioSession];

            // [TBMDeviceHandler showAllAudioDevices];
            if (![self getAudioCaptureInputWithError:&blockError]){
                OB_ERROR(@"VideoRecorder: Unable to getAudioCaptureInput");
                return;
            }

            [_captureSession addInput:_audioInput];
            OB_INFO(@"Added audioInput: %@", _audioInput);
            
            //
            // Output
            //
            _captureOutput = [[AVCaptureMovieFileOutput alloc] init];
            if (![self addCaptureOutputWithError:&blockError]){
                OB_ERROR(@"VideoRecorder: Unable to addCaptureOutput");
                return;
            }
            OB_INFO(@"Added captureOutput: %@", _captureOutput);
            
            //
            // Observers
            //
            [self addObservers];
            OB_INFO(@"VideoRecorder added observers.");

            //
            // StartRunning
            //
            [self.captureSession startRunning];
            
        });
    }
    return self;
}

// Unused?
- (void)startPreview{
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession startRunning];
    });
}

- (AVCaptureSession *)setupSessionWithError:(NSError * __autoreleasing *)error{
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (![_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]){
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Cannot set AVCaptureSessionPresetLow", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    _captureSession.sessionPreset = AVCaptureSessionPresetLow;
    return _captureSession;
}

- (AVAudioSession *)setupAudioSession{
    _audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error)
        OB_ERROR(@"ERROR: unable to set audiosession to AVAudioSessionCategoryPlayAndRecord ERROR: %@", error);
    
    error = nil;
    [_audioSession setMode:AVAudioSessionModeVideoChat error:&error];
    if (error)
        OB_ERROR(@"ERROR: unable to set audiosession to AVAudioSessionModeVideoChat ERROR: %@", error);
    
    error = nil;
    if (![_audioSession setActive:YES error:&error])
        OB_ERROR(@"ERROR: unable to activate audiosession ERROR: %@", error);

    return _audioSession;
}

- (AVCaptureInput *)getVideoCaptureInputWithError:(NSError **)error{
    _videoInput = [TBMDeviceHandler getAvailableFrontVideoInputWithError:&*error];
    return _videoInput;
}

- (AVCaptureInput *)getAudioCaptureInputWithError:(NSError * __autoreleasing *)error{
    _audioInput = [TBMDeviceHandler getAudioInputWithError:&*error];
    return _audioInput;
}

- (AVCaptureSession *)addCaptureOutputWithError:(NSError **)error{
    if (![_captureSession canAddOutput:_captureOutput]) {
        OB_ERROR(@"VideoRecorder: addCaptureOutputWithError: Could not add captureOutput");
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: @"Could not add captureOutput to capture session.", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    [_captureSession addOutput:_captureOutput];
    return _captureSession;
}

//--------------------------
// Set videoRecorderDelegate
//--------------------------
- (void)setVideoRecorderDelegate:(id)delegate{
    _delegate = delegate;
}

- (void)removeVideoRecorderDelegate{
    _delegate = nil;
}

//-------------
// Query status
//-------------
- (BOOL)isRecording{
    return [self.captureOutput isRecording];
}

//-------------------
// Handle previewView
//-------------------
- (void)setupPreviewView{
    // Remove all sublayers that might have been added by calling this previously.
    self.previewView.layer.sublayers = nil;
    
    [self connectVideoCaptureToPreview];
    [self setupRecordingOverlay];
}


- (void)connectVideoCaptureToPreview{
    CALayer * videoViewLayer = _previewView.layer;
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = _previewView.bounds;
    [videoViewLayer addSublayer:previewLayer];
}

- (void)setupRecordingOverlay{
    [self addRedBorderAndDot];
    [self addRecordingLabel];
}

static const float LayoutConstRecordingLabelHeight = 22;
static const float LayoutConstRecordingLabelFontSize = 0.55 * LayoutConstRecordingLabelHeight;
static NSString *LayoutConstRecordingLabelBackgroundColor = @"000";
static NSString *LayoutConstWhiteTextColor  = @"fff";
static const float LayoutConstRecordingBorderWidth = 2;

- (void)addRecordingLabel{
    float y = self.previewView.bounds.size.height - LayoutConstRecordingLabelHeight;
    float width = self.previewView.frame.size.width - 2*LayoutConstRecordingBorderWidth;
    float height = LayoutConstRecordingLabelHeight - LayoutConstRecordingBorderWidth;
    self.recordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(LayoutConstRecordingBorderWidth, y, width, height)];
    self.recordingLabel.hidden = YES;
    self.recordingLabel.text = @"Recording";
    self.recordingLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstRecordingLabelBackgroundColor alpha:0.5];
    self.recordingLabel.textColor = [UIColor colorWithHexString:LayoutConstWhiteTextColor alpha:1];
    self.recordingLabel.textAlignment = NSTextAlignmentCenter;
    self.recordingLabel.font = [UIFont systemFontOfSize:LayoutConstRecordingLabelFontSize];
    [self.previewView addSubview:self.recordingLabel];
}

- (void)addRedBorderAndDot{
    _recordingOverlay = [CALayer layer];
    _recordingOverlay.hidden = YES;
    _recordingOverlay.frame = _previewView.bounds;
    _recordingOverlay.cornerRadius = 2;
    _recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
    _recordingOverlay.borderWidth = LayoutConstRecordingBorderWidth;
    _recordingOverlay.borderColor = [UIColor redColor].CGColor;
    _recordingOverlay.delegate = self;
    [_previewView.layer addSublayer:_recordingOverlay];
    [_recordingOverlay setNeedsDisplay];
}

// The callback by the recording overlay CALayer due to setNeedsDisplay. Use it to add the dot to recordingOverlay
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    // Simplify the view and dont draw the red dot.
    // [self addDotInContext:context];
}

- (void)addDotInContext:(CGContextRef)context{
    CGRect borderRect = CGRectMake(8, 8, 7, 7);
    CGContextSetRGBFillColor(context, 248, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

//------------------
// Recording actions
//------------------
- (void)startRecordingWithMarker:(NSString *)marker{
    [_dingSoundEffect play];
    self.didCancelRecording = NO;
    _marker = marker;
    OB_INFO(@"Started recording with marker %@", _marker);
    NSError *error = nil;
    [_fileManager removeItemAtURL:_recordingVideoUrl error:&error];
    
    // Wait so we don't record our own ding.
    [NSThread sleepForTimeInterval:0.4f];
    [_captureOutput startRecordingToOutputFileURL:_recordingVideoUrl recordingDelegate:self];
    [self showRecordingOverlay];
}

- (void)stopRecording{
    [self hideRecordingOverlay];
    if ([_captureOutput isRecording])
        [_captureOutput stopRecording];
    
    // Wait so final ding isn't part of recording
    [NSThread sleepForTimeInterval:0.1f];
    [_dingSoundEffect play];
}

- (BOOL)cancelRecording{
    self.didCancelRecording = YES;
    BOOL wasRecording = [self.captureOutput isRecording];
    [self stopRecording];
    return wasRecording;
}

- (void)showRecordingOverlay{
    _recordingOverlay.hidden = NO;
    self.recordingLabel.hidden = NO;
}

- (void)hideRecordingOverlay{
    _recordingOverlay.hidden = YES;
    self.recordingLabel.hidden = YES;
}


//------------------------------------------------
// Recording Finished callback and post processing
//------------------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    OB_INFO(@"didFinishRecording.");
    if (self.didCancelRecording)
        return;
    
    if (error){
		OB_ERROR(@"%@", error);
        return;
    }
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:[_recordingVideoUrl path] error:&error];
    OB_INFO(@"Recorded file size = %llu", fileAttributes.fileSize);
    
    [self convertOutgoingFileToMpeg4];
}

- (void)convertOutgoingFileToMpeg4{
    NSError *dontCareError = nil;
    [_fileManager removeItemAtURL:_recordedVideoMpeg4Url error:&dontCareError];
    
    AVAsset *asset = [AVAsset assetWithURL:_recordingVideoUrl];
    NSArray *allPresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    DebugLog(@"%@", allPresets);
    
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    DebugLog(@"Filetypes: %@", session.supportedFileTypes);
    
    session.outputFileType = AVFileTypeMPEG4;
    session.outputURL = _recordedVideoMpeg4Url;
    [session exportAsynchronouslyWithCompletionHandler:^{[self didFinishConvertingToMpeg4];}];
}

- (void)didFinishConvertingToMpeg4{
    NSError *error = nil;
    [self moveRecordingToOutgoingFileWithError:&error];
    if (error){
        OB_ERROR(@"ERROR2: moveRecordingToOutgoingFileWithError this should never happen. error=%@", error);
        return;
    }
        
    DebugLog(@"calling delegate=%@", _delegate);
    if (self.delegate != nil){
        [self.delegate didFinishVideoRecordingWithMarker:_marker];
    } else {
        OB_ERROR(@"VideoRecorder: no videoRecorderDelegate");
    }
}

- (void)moveRecordingToOutgoingFileWithError:(NSError **)error{
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithMarker:_marker];
    
    NSError *dontCareError = nil;
    [_fileManager removeItemAtURL:outgoingVideoUrl error:&dontCareError];
    
    *error = nil;
    [_fileManager moveItemAtURL:_recordedVideoMpeg4Url toURL:outgoingVideoUrl error:&*error];
    if (*error) {
        OB_ERROR(@"ERROR: moveRecordingToOutgoingFile: ERROR: unable to move file. This should never happen. %@", *error);
        return;
    }
    
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:outgoingVideoUrl.path error:&dontCareError];
    DebugLog(@"moveRecordingToOutgoingFile: Outgoing file size %llu", fileAttributes.fileSize);
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
        [self removeVideoRecorderDelegate];
        [self.captureSession stopRunning];
    });
}

- (void)addObservers{
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

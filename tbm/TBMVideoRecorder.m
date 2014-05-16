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
#import "TBMFriend.h"

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>
@property AVCaptureSession *captureSession;
@property AVAudioSession *audioSession;
@property AVCaptureInput *videoInput;
@property AVCaptureInput *audioInput;
@property NSFileManager *fileManager;
@property AVCaptureMovieFileOutput *captureOutput;
@property NSURL *videosDirectoryUrl;
@property NSURL *recordingVideoUrl;
@property CALayer *recordingOverlay;
@property TBMSoundEffect *dingSoundEffect;
@property NSString *friendId;
@end

@implementation TBMVideoRecorder

+ (NSURL *)outgoingVideoUrlWithFriendId:(NSString *)friendId
{
    NSString *filename = [NSString stringWithFormat:@"outgoingVidToFriend%@", friendId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

-(instancetype)initWithPreivewView:(UIView *)previewView TBMVideoRecorderDelegate:(id)delegate error:(NSError **)error{
    self = [super init];
    if (self){
        _delegate = delegate;
        _fileManager = [NSFileManager defaultManager];
        _previewView = previewView;
        _videosDirectoryUrl = [TBMConfig videosDirectoryUrl];
        _recordingVideoUrl = [_videosDirectoryUrl URLByAppendingPathComponent:[@"new" stringByAppendingPathExtension:@"mov"]];
        _dingSoundEffect = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];
        
        DebugLog(@"Setting up preview on view: %@", _previewView);
        
        [self setupAudioSession];
        
        if (![self setupSessionWithError:&*error])
            return nil;
        DebugLog(@"Set up session: %@", _captureSession);

        if (![self getVideoCaptureInputWithError:&*error])
            return nil;
        [_captureSession addInput:_videoInput];
        DebugLog(@"Added videoInput: %@", _videoInput);

        [TBMDeviceHandler showAllAudioDevices];
        if (![self getAudioCaptureInputWithError:&*error])
            return nil;
        [_captureSession addInput:_audioInput];
        DebugLog(@"Added audioInput: %@", _audioInput);

        _captureOutput = [[AVCaptureMovieFileOutput alloc] init];
        if (![self addCaptureOutputWithError:&*error])
            return nil;
        DebugLog(@"Added captureOutput: %@", _captureOutput);

        [self setupPreview];
        [self setupRecordingOverlay];
        [self startPreview];
    }
    return self;
}

- (AVCaptureSession *)setupSessionWithError:(NSError **)error{
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (![_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]){
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Cannot set AVCaptureSessionPresetLow", NSLocalizedFailureReasonErrorKey, nil];
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
        DebugLog(@"ERROR: unable to set audiosession to AVAudioSessionCategoryPlayAndRecord ERROR: %@", error);
    
    error = nil;
    [_audioSession setMode:AVAudioSessionModeVideoChat error:&error];
    if (error)
        DebugLog(@"ERROR: unable to set audiosession to AVAudioSessionModeVideoChat ERROR: %@", error);
    
    error = nil;
    if (![_audioSession setActive:YES error:&error])
        DebugLog(@"ERROR: unable to activate audiosession ERROR: %@", error);

    return _audioSession;
}

- (AVCaptureInput *)getVideoCaptureInputWithError:(NSError **)error{
    _videoInput = [TBMDeviceHandler getAvailableFrontVideoInputWithError:&*error];
    return _videoInput;
}

- (AVCaptureInput *)getAudioCaptureInputWithError:(NSError **)error{
    _audioInput = [TBMDeviceHandler getAudioInputWithError:&*error];
    return _audioInput;
}

- (void)setupPreview
{
    CALayer * videoViewLayer = _previewView.layer;
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = _previewView.bounds;
    [videoViewLayer addSublayer:previewLayer];
}

- (void)setupRecordingOverlay
{
    _recordingOverlay = [CALayer layer];
    _recordingOverlay.hidden = YES;
    _recordingOverlay.frame = _previewView.bounds;
    _recordingOverlay.cornerRadius = 2;
    _recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
    _recordingOverlay.borderWidth = 2;
    _recordingOverlay.borderColor = [UIColor redColor].CGColor;
    _recordingOverlay.delegate = self;
    [_previewView.layer addSublayer:_recordingOverlay];
    [_recordingOverlay setNeedsDisplay];
}

// The callback by the recording overlay CALayer. Use it to add the dot to recordingOverlay
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGRect borderRect = CGRectMake(8, 8, 7, 7);
    CGContextSetRGBFillColor(context, 248, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

- (void)startPreview
{
    [_captureSession startRunning];
}

- (void)startRecordingWithFriendId:(NSString *)friendId
{
    [_dingSoundEffect play];
    _friendId = friendId;
    DebugLog(@"Started recording with friendId %@", _friendId);
    NSError *error = nil;
    [_fileManager removeItemAtURL:_recordingVideoUrl error:&error];
    
    // Wait so we don't record our own ding.
    [NSThread sleepForTimeInterval:0.2f];
    [_captureOutput startRecordingToOutputFileURL:_recordingVideoUrl recordingDelegate:self];
    [self showRecordingOverlay];
}

- (void)stopRecording
{
    [self hideRecordingOverlay];
    [_captureOutput stopRecording];
    [_dingSoundEffect play];
}

- (void)cancelRecording
{
    [self hideRecordingOverlay];
    [_dingSoundEffect play];
}

- (void)showRecordingOverlay
{
    _recordingOverlay.hidden = NO;
}

- (void)hideRecordingOverlay
{
    _recordingOverlay.hidden = YES;
}

- (void)moveRecordingToOutgoingFileWithError:(NSError **)error
{
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:_friendId];
    
    NSError *dontCareError = nil;
    
    [_fileManager removeItemAtURL:outgoingVideoUrl error:&dontCareError];
    
    *error = nil;
    [_fileManager moveItemAtURL:_recordingVideoUrl toURL:outgoingVideoUrl error:&*error];
    if (*error) {
        DebugLog(@"ERROR: moveRecordingToOutgoingFile: ERROR: unable to move file. This should never happen. %@", *error);
        return;
    }
    
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:outgoingVideoUrl.path error:&dontCareError];
    DebugLog(@"moveRecordingToOutgoingFile: Outgoing file size %llu", fileAttributes.fileSize);
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    DebugLog(@"didFinishRecording.");
    if (error){
		DebugLog(@"%@", error);
        return;
    }
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:[_recordingVideoUrl path] error:&error];
    DebugLog(@"Recorded file size = %llu", fileAttributes.fileSize);
    
    error = nil;
    [self moveRecordingToOutgoingFileWithError:&error];
    if (error){
        DebugLog(@"ERROR2: moveRecordingToOutgoingFileWithError this should never happen. error=%@", error);
        return;
    }
    
    TBMFriend *friend = [TBMFriend findWithId:_friendId];
    [friend setUploadRetryCountWithInteger:0];
    [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW];
    [TBMFriend saveAll];
    
    DebugLog(@"didFinishRecording calling delegate=%@", _delegate);
    [_delegate didFinishVideoRecordingWithFriendId:_friendId];
}

- (AVCaptureSession *)addCaptureOutputWithError:(NSError **)error
{
    if (![_captureSession canAddOutput:_captureOutput]) {
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Could not add captureOutput to capture session.", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    [_captureSession addOutput:_captureOutput];
    return _captureSession;
}

@end

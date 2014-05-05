//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMCameraHandler.h"
#import "TBMSoundEffect.h"
#import "TBMConfig.h"

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>
@property AVCaptureSession *captureSession;
@property AVCaptureInput *captureInput;
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

-(id)initWithPreivewView:(UIView *)previewView error:(NSError **)error
{
    self = [super init];
    if (self){
        _fileManager = [NSFileManager defaultManager];
        _previewView = previewView;
        _videosDirectoryUrl = [TBMConfig videosDirectoryUrl];
        _recordingVideoUrl = [_videosDirectoryUrl URLByAppendingPathComponent:[@"new" stringByAppendingPathExtension:@"mov"]];
        _dingSoundEffect = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];
        
        DebugLog(@"TBMVideoRecorder: Setting up preview on view: %@", _previewView);
        
        if (![self setupSessionWithError:&*error])
            return nil;
        DebugLog(@"TBMVideoRecorder: Set up session: %@", _captureSession);

        if (![self getCaptureInputWithError:&*error])
            return nil;
        [_captureSession addInput:_captureInput];
        DebugLog(@"TBMVideoRecorder: Added captureInput: %@", _captureInput);

        _captureOutput = [[AVCaptureMovieFileOutput alloc] init];
        if (![self addCaptureOutputWithError:&*error])
            return nil;
        DebugLog(@"TBMVideoRecorder: Added captureOutput: %@", _captureOutput);

        [self setupPreview];
        [self setupRecordingOverlay];
        [self startPreview];
    }
    return self;
}

- (AVCaptureSession *)setupSessionWithError:(NSError **)error{
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (![_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]){
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Cannot set AVCaptureSessionPreset640x480", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    return _captureSession;
}

- (AVCaptureInput *)getCaptureInputWithError:(NSError **)error
{
    _captureInput = [TBMCameraHandler getAvailableFrontVideoInputWithError:&*error];
    return _captureInput;
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
    _friendId = friendId;
    DebugLog(@"TBMVideoRecorder: Started recording with friendId %@", _friendId);
    NSError *error = nil;
    [_fileManager removeItemAtURL:_recordingVideoUrl error:&error];
    [_captureOutput startRecordingToOutputFileURL:_recordingVideoUrl recordingDelegate:self];
    [_dingSoundEffect play];
    [self showRecordingOverlay];
}

- (void)stopRecording
{
    [self hideRecordingOverlay];
    [_dingSoundEffect play];
    [_captureOutput stopRecording];
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

- (void)moveRecordingToOutgoingFile
{
    NSError *error = nil;
    
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:_friendId];
    [_fileManager removeItemAtURL:outgoingVideoUrl error:&error];
    [_fileManager moveItemAtURL:_recordingVideoUrl toURL:outgoingVideoUrl error:&error];
    NSDictionary *ova = [_fileManager attributesOfItemAtPath:outgoingVideoUrl.path error:&error];
    DebugLog(@"TBMVideoRecorder: recorded filesize=%llu path=%@", ova.fileSize, outgoingVideoUrl.path);
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    DebugLog(@"TBMVideoRecorder: didFinishRecording.");
    if (error){
		DebugLog(@"%@", error);
        return;
    }
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:[_recordingVideoUrl path] error:&error];
    DebugLog(@"TBMVideoRecorder: recorded file size = %llu", fileAttributes.fileSize);
    [self moveRecordingToOutgoingFile];
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

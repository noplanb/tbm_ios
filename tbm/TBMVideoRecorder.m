//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMCameraHandler.h"

@implementation TBMVideoRecorder

-(id)initWithPreivewView:(UIView *)previewView error:(NSError **)error
{
    self = [super init];
    if (self){
        _previewView = previewView;
        NSLog(@"TBMVideoRecorder: Setting up preview on view: %@", _previewView);
        if (![self setupSessionWithError:&*error]){
            return nil;
        }
        NSLog(@"TBMVideoRecorder: Set up session: %@", _captureSession);

        if (![self getCaptureInputWithError:&*error]){
            return nil;
        }
        NSLog(@"TBMVideoRecorder: Got captureInput: %@", _captureInput);
        [_captureSession addInput:_captureInput];
        [self setupPreview];
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

- (void)startPreview
{
    [_captureSession startRunning];
}

@end

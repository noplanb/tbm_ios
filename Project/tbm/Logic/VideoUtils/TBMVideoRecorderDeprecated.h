//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"
#import "AVAudioSession+TBMAudioSession.h"


@protocol TBMVideoRecorderDelegate <NSObject>

- (void)videoRecorderDidStartRunning;

- (void)videoRecorderDidStartRecording;
- (void)videoRecorderDidStopRecording;
- (void)videoRecorderDidStopButDidNotStartRecording;

- (void)videoRecorderDidFinishRecordingWithURL:(NSURL*)url error:(NSError*)error;


- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount;

@end

@interface TBMVideoRecorderDeprecated : NSObject <TBMAudioSessionDelegate>

@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;
@property (nonatomic, assign) AVCaptureDevicePosition device;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureInput *videoInput;
@property (nonatomic, strong) AVCaptureInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureOutput;

- (void)setupCaptureSessionView:(UIView*)view;
- (void)startRunning;
- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl;
- (void)stopRecording;
- (BOOL)cancelRecording;
- (BOOL)isRecording;
- (void)initVideoInput;

- (void)removeAudioInput;
- (void)addAudioInput;

@end

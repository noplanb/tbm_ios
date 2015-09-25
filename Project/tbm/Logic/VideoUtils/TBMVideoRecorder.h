//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"
#import "TBMPreviewView.h"
#import "AVAudioSession+TBMAudioSession.h"

extern NSString* const TBMVideoRecorderDidFinishRecording;
extern NSString* const TBMVideoRecorderShouldStartRecording;
extern NSString* const TBMVideoRecorderDidCancelRecording;
extern NSString* const TBMVideoRecorderDidFail;

@protocol TBMVideoRecorderDelegate <NSObject>

- (void)videoRecorderDidStartRunning;

- (void)videoRecorderDidStartRecording;
- (void)videoRecorderDidStopRecording;
- (void)videoRecorderDidStopButDidNotStartRecording;

- (void)videoRecorderDidFinishRecordingWithURL:(NSURL*)url error:(NSError*)error;


- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount;

@end

@interface TBMVideoRecorder : NSObject <TBMAudioSessionDelegate>

@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;
@property (nonatomic, assign) AVCaptureDevicePosition device;

- (void)setupCaptureSessionView:(UIView*)view;
- (void)startRunning;
- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl;
- (void)stopRecording;
- (BOOL)cancelRecording;
- (void)dispose;
- (BOOL)isRecording;

@end

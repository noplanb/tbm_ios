//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by Sani Elfishawy on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface ZZVideoRecorder : NSObject

extern NSString* const kVideoProcessorDidFinishProcessing;
extern NSString* const kVideoProcessorDidFail;
extern NSString* const kZZVideoRecorderDidFinishRecording;
extern NSString* const kZZVideoRecorderShouldStartRecording;
extern NSString* const kZZVideoRecorderDidCancelRecording;
extern NSString* const kZZVideoRecorderDidFail;

@property (nonatomic, assign) BOOL didCancelRecording;
@property (nonatomic, assign) BOOL wasRecordingStopped;

+ (instancetype)shared;

- (AVCaptureVideoPreviewLayer *)previewLayer;
- (void)startPreview;

- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;
- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;
- (void)cancelRecordingWithReason:(NSString*)reason;

- (void)cancelRecording;

- (void)stopAudioSession;
- (void)startAudioSession;

- (BOOL)isRecording;
- (void)showVideoToShoortToast;

@end

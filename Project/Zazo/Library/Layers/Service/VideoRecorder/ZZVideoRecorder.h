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

extern NSString* const kZZVideoRecorderDidStartVideoCapture;
extern NSString* const kZZVideoRecorderDidEndVideoCapture;

extern CGFloat const kZZVideoRecorderDelayBeforeNextMessage;

+ (instancetype)shared;
- (void)setup;

- (AVCaptureVideoPreviewLayer *)previewLayer;
- (void)startPreview;
- (void)stopPreview;

- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;
- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;
- (void)cancelRecordingWithReason:(NSString*)reason;

- (void)cancelRecording;

- (BOOL)isRecording;

@property (nonatomic, assign, readonly) BOOL isCompleting; //stopRecordingWithCompletionBlock started, but havent't dispatched all blocks yet

- (void)showVideoToShortToast;

@end

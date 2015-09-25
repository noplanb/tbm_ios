//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZVideoRecorderDelegate <NSObject>

- (void)videoRecordingCanceled;

@end

@interface ZZVideoRecorder : NSObject

extern NSString* const kVideoProcessorDidFinishProcessing;
extern NSString* const kVideoProcessorDidFail;
extern NSString* const TBMVideoRecorderDidFinishRecording;
extern NSString* const TBMVideoRecorderShouldStartRecording;
extern NSString* const TBMVideoRecorderDidCancelRecording;
extern NSString* const TBMVideoRecorderDidFail;

@property (nonatomic, assign) BOOL didCancelRecording;

+ (instancetype)shared;

- (void)updateRecordView:(UIView*)recordView;
- (void)startRecordingWithVideoURL:(NSURL*)url;

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;
- (void)cancelRecordingWithReason:(NSString*)reason;
- (void)updateRecorder;

- (void)addDelegate:(id<ZZVideoRecorderDelegate>)delegate;
- (void)removeDelegate:(id<ZZVideoRecorderDelegate>)delegate;
- (void)cancelRecording;

@end

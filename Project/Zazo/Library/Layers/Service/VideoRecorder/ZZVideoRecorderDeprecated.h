//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZVideoRecorderInterfaceDelegate <NSObject>

- (UIView*)recordingView;

@end


@protocol ZZVideoRecorderDelegate <NSObject>

- (void)videoRecordingCanceled;

@end

@interface ZZVideoRecorderDeprecated : NSObject

extern NSString* const kVideoProcessorDidFinishProcessing;
extern NSString* const kVideoProcessorDidFail;
extern NSString* const TBMVideoRecorderDidFinishRecording;
extern NSString* const TBMVideoRecorderShouldStartRecording;
extern NSString* const TBMVideoRecorderDidCancelRecording;
extern NSString* const TBMVideoRecorderDidFail;

@property (nonatomic, assign) BOOL didCancelRecording;
@property (nonatomic, assign) BOOL isRecorderActive;
@property (nonatomic, assign) BOOL isRecordingInProgress;
@property (nonatomic, assign) BOOL wasRecordingStopped;
@property (nonatomic, weak) id <ZZVideoRecorderInterfaceDelegate> interfaceDelegate;

+ (instancetype)shared;

- (void)updateRecordView:(UIView*)recordView;
- (void)startRecordingWithVideoURL:(NSURL*)url completionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (void)stopRecordingWithCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;
- (void)cancelRecordingWithReason:(NSString*)reason;
- (void)updateRecorder;

- (void)addDelegate:(id<ZZVideoRecorderDelegate>)delegate;
- (void)removeDelegate:(id<ZZVideoRecorderDelegate>)delegate;
- (void)cancelRecording;

- (void)stopAudioSession;
- (void)startAudioSession;

- (BOOL)isRecording;
- (void)showVideoToShoortToast;

@end

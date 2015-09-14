//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZVideoRecorder : NSObject

extern NSString* const kVideoProcessorDidFinishProcessing;
extern NSString* const kVideoProcessorDidFail;
extern NSString* const TBMVideoRecorderDidFinishRecording;
extern NSString* const TBMVideoRecorderShouldStartRecording;
extern NSString* const TBMVideoRecorderDidCancelRecording;
extern NSString* const TBMVideoRecorderDidFail;

+ (instancetype)shared;

- (void)updateRecordView:(UIView*)recordView;
- (void)startRecordingWithVideoURL:(NSURL*)url;

- (void)stopRecording;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;
- (void)cancelRecordingWithReason:(NSString*)reason;

@end

//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZVideoRecorder : NSObject

+ (instancetype)shared;

- (void)updateRecordView:(UIView*)recordView;
- (void)startRecordingWithVideoURL:(NSURL*)url;

- (void)stopRecording;

- (BOOL)areBothCamerasAvailable;
- (void)switchCamera;

@end

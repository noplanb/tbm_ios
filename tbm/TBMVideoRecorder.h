//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
@protocol TBMVideoRecorderDelegate <NSObject>
- (void)didFinishVideoRecordingWithMarker:(NSString *)marker;
- (void)videoRecorderDidStartRunning;
- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount;
@end

@interface TBMVideoRecorder : NSObject

@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker;

- (instancetype)initWithPreviewView:(UIView *)previewView delegate:(id)delegate error:(NSError * __autoreleasing *)error;
- (void)setVideoRecorderDelegate:(id)delegate;
- (void)removeVideoRecorderDelegate;
- (void)startPreview;
- (void)startRecordingWithMarker:(NSString *)marker;
- (void)stopRecording;
- (void)cancelRecording;
- (void)dispose;
@end

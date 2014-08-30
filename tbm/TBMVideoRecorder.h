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
@end

@interface TBMVideoRecorder : NSObject

@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker;

- (instancetype)initWithError:(NSError **)error;
- (void)setupPreviewView:(UIView *)previewView;
- (void)setVideoRecorderDelegate:(id)delegate;
- (void)removeVideoRecorderDelegate;
- (void)startPreview;
- (void)stopPreview;
- (void)startRecordingWithMarker:(NSString *)marker;
- (void)stopRecording;
- (void)cancelRecording;
- (void)dispose;
@end

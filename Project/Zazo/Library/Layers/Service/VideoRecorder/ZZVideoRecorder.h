//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZGridBaseCell, ZZGridCollectionCell;

@interface ZZVideoRecorder : NSObject

- (void)updateViewGridCell:(ZZGridBaseCell *)cell;
- (void)startRunning;
- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl;
- (void)stopRecording;
- (BOOL)cancelRecording;
- (void)dispose;
- (BOOL)isRecording;
- (void)startRecordingWithGridCell:(ZZGridCollectionCell*)gridCell;


@end

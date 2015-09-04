//
//  ZZVideoRecorder.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridBaseCell, ZZGridCollectionCell;

@interface ZZVideoRecorder : NSObject


+ (instancetype)sharedInstance;

- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl;
- (void)stopRecording;


- (void)updateViewGridCell:(ZZGridBaseCell *)cell;
- (void)startRecordingWithGridCell:(ZZGridCollectionCell*)gridCell;
- (BOOL)isBothCamerasAvailable;
- (void)switchToFrontCamera;
- (void)switchToBackCamera;

@end

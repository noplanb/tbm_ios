//
//  ZZDeviceHandler.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AVFoundation;

@interface ZZDeviceHandlerDeprecated : NSObject

#pragma mark - Video

+ (AVCaptureDeviceInput *)loadAvailableFrontVideoInputWithError:(NSError *__autoreleasing *)error;

+ (AVCaptureDeviceInput *)loadAvailableBackVideoInputWithError:(NSError *__autoreleasing *)error;

+ (BOOL)isCameraConnected;

+ (BOOL)areBothCamerasAvailable;


#pragma mark - Audio

+ (AVCaptureDeviceInput *)loadAudioInputWithError:(NSError *__autoreleasing *)error;

+ (BOOL)isMicrophoneConnected;

@end

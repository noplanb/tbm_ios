//
//  ZZDeviceHandler.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AVFoundation;

@interface ZZDeviceHandler : NSObject

+ (AVCaptureDeviceInput *)getAudioInputWithError:(NSError * __autoreleasing *)error;
+ (AVCaptureDeviceInput *)getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error;
+ (AVCaptureDeviceInput *)getAvailableBackVideoInputWithError:(NSError * __autoreleasing *)error;
+ (BOOL)isCameraConnected;
+ (BOOL)isMiccrophoneConnected;
+ (BOOL)areBothCamerasAvailable;

@end

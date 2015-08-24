//
//  TBMCameraHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMDeviceHandler.h"
#import "OBLogger.h"

@implementation TBMDeviceHandler

#pragma mark - Video

+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error {
    
    AVCaptureDevice *device = [TBMDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    if (!device) {
        *error = [[NSError alloc] initWithDomain:@"TBM" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device has no camera"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}

+ (BOOL) isCameraConnected{
    AVCaptureDevice *device = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    if (device == nil){
        OB_WARN(@"TBMDeviceHandler#isCameraConnected isCameraAvailable: got no camera");
        return NO;
    }
    if (device.connected == NO){
        OB_WARN(@"TBMDeviceHandler#isCameraConnected isCameraAvailable: camera not Connected");
        return NO;
    }
    return YES;
}

#pragma mark - Audio

+ (AVCaptureDeviceInput *)getAudioInputWithError:(NSError * __autoreleasing *)error {
    
    AVCaptureDevice *mic = [self getMicrophone];
    if (mic == nil) {
        *error = [[NSError alloc] initWithDomain:@"TBM" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device has no microphone"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&*error];
    return input;
}

+ (BOOL) isMiccrophoneConnected{
    AVCaptureDevice *mic = [self getMicrophone];
    if (mic == nil){
        OB_WARN(@"TBMDeviceHandler#isMiccrophoneConnected isMicrophoneAvailable: got no mic");
        return NO;
    }
    if (mic.connected == NO){
        OB_WARN(@"TBMDeviceHandler#isMiccrophoneConnected isMiccrophoneAvailable: camera not Connected");
        return NO;
    }
    return YES;
}

+ (AVCaptureDevice *) getMicrophone{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
}

#pragma mark - Private

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}


@end
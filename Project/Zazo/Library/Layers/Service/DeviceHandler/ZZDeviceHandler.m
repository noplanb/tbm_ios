//
//  ZZDeviceHandler.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDeviceHandler.h"

@implementation ZZDeviceHandler


#pragma mark - Video

+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error
{
    
    AVCaptureDevice *device = [ZZDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    if (!device)
    {
        *error = [[NSError alloc] initWithDomain:@"ZZ" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device has no camera"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}

+ (AVCaptureDeviceInput *)getAvailableBackVideoInputWithError:(NSError * __autoreleasing *)error
{
    AVCaptureDevice *device = [ZZDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    if (!device)
    {
        *error = [[NSError alloc] initWithDomain:@"ZZ" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device has no camera"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}


+ (BOOL) isCameraConnected
{
    AVCaptureDevice *device = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    if (!device)
    {
         return NO;
    }
    
    if (!device.connected)
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isBothCamerasAvailable
{
    
    AVCaptureDevice* frondCamera = [ZZDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    AVCaptureDevice* backCamera = [ZZDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];

    return (frondCamera && backCamera);
}

#pragma mark - Audio

+ (AVCaptureDeviceInput *)getAudioInputWithError:(NSError * __autoreleasing *)error
{
    
    AVCaptureDevice *mic = [self getMicrophone];
    if (!mic)
    {
        *error = [[NSError alloc] initWithDomain:@"ZZ" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device has no microphone"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&*error];
    return input;
}

+ (BOOL) isMiccrophoneConnected
{
    AVCaptureDevice *mic = [self getMicrophone];
    if (!mic || !mic.connected)
    {
        return NO;
    }
    
    return YES;
}

+ (AVCaptureDevice *) getMicrophone
{
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

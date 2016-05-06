//
//  ZZDeviceHandler.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDeviceHandlerDeprecated.h"

@implementation ZZDeviceHandlerDeprecated


#pragma mark - Video

+ (AVCaptureDeviceInput *)loadAvailableFrontVideoInputWithError:(NSError *__autoreleasing *)error
{
    return [self _loadAvailableVideoInputWithType:AVCaptureDevicePositionFront error:error];
}

+ (AVCaptureDeviceInput *)loadAvailableBackVideoInputWithError:(NSError *__autoreleasing *)error
{
    return [self _loadAvailableVideoInputWithType:AVCaptureDevicePositionBack error:error];
}

+ (BOOL)areBothCamerasAvailable
{
    AVCaptureDevice *frondCamera = [self _deviceWithMediaType:AVMediaTypeVideo
                                           preferringPosition:AVCaptureDevicePositionFront];

    AVCaptureDevice *backCamera = [self _deviceWithMediaType:AVMediaTypeVideo
                                          preferringPosition:AVCaptureDevicePositionBack];

    return (frondCamera && backCamera);
}

+ (BOOL)isCameraConnected
{
    AVCaptureDevice *device = [self _deviceWithMediaType:AVMediaTypeVideo
                                      preferringPosition:AVCaptureDevicePositionFront];
    if (device == nil)
    {
        ZZLogWarning(@"TBMDeviceHandler#isCameraConnected isCameraAvailable: got no camera");
        return NO;
    }
    if (device.connected == NO)
    {
        ZZLogWarning(@"TBMDeviceHandler#isCameraConnected isCameraAvailable: camera not Connected");
        return NO;
    }
    return YES;
}


#pragma mark - Audio

+ (AVCaptureDeviceInput *)loadAudioInputWithError:(NSError *__autoreleasing *)error
{
    AVCaptureDevice *mic = [self _loadMicrophone];
    if (mic == nil)
    {
        //TODO: error generator
        *error = [[NSError alloc] initWithDomain:@"Zazo" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Device has no microphone"}];
        return nil;
    }
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&*error];
    return input;
}

+ (BOOL)isMicrophoneConnected
{
    AVCaptureDevice *mic = [self _loadMicrophone];
    if (mic == nil)
    {
        ZZLogWarning(@"TBMDeviceHandler#isMiccrophoneConnected isMicrophoneAvailable: got no mic");
        return NO;
    }
    if (mic.connected == NO)
    {
        ZZLogWarning(@"TBMDeviceHandler#isMiccrophoneConnected isMiccrophoneAvailable: camera not Connected");
        return NO;
    }
    return YES;
}


#pragma mark - Private

+ (AVCaptureDeviceInput *)_loadAvailableVideoInputWithType:(AVCaptureDevicePosition)type error:(NSError *__autoreleasing *)error
{
    AVCaptureDevice *device = [self _deviceWithMediaType:AVMediaTypeVideo preferringPosition:type];
    if (!device)
    {
        //TODO: error generator
        *error = [[NSError alloc] initWithDomain:@"Zazo" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Device has no camera"}];
        return nil;
    }
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}

+ (AVCaptureDevice *)_loadMicrophone
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
}

+ (AVCaptureDevice *)_deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    __block AVCaptureDevice *captureDevice = [devices firstObject];

    [devices enumerateObjectsUsingBlock:^(AVCaptureDevice *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

        if (obj.position == position)
        {
            captureDevice = obj;
            *stop = YES;
        }
    }];

    return captureDevice;
}

@end

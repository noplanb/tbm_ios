//
//  TBMCameraHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMDeviceHandler.h"

@implementation TBMDeviceHandler

#pragma mark - Convenience

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

#pragma mark - Video

+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error {
    
    AVCaptureDevice *device = [TBMDeviceHandler deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    if (!device) {
        *error = [[NSError alloc] initWithDomain:@"TBM" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device hasn't any video capture devices"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}

#pragma mark - Audio

+ (AVCaptureDeviceInput *)getAudioInputWithError:(NSError * __autoreleasing *)error {
    
    AVCaptureDevice *device = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    if (!device) {
        *error = [[NSError alloc] initWithDomain:@"TBM" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Device hasn't any audio capture devices"}];
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    return input;
}

@end
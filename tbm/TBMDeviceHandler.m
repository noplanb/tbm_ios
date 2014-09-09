//
//  TBMCameraHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMDeviceHandler.h"

@implementation TBMDeviceHandler

// -----
// Video
// -----
+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error{
    AVCaptureDevice *device = [TBMDeviceHandler getAvailableFrontVideoCameraWithError:&*error];
    if (!device){
        return nil;
    }
    AVCaptureDeviceInput *input = [TBMDeviceHandler getInputWithDevice:device error:&*error];
    if (!input){
        DebugLog(@"ERROR: Could not get video input");
        return nil;
    }
    DebugLog(@"TBMCameraHandler: Got available input: %@", input);
    return input;
}

+ (AVCaptureDevice *)getAvailableFrontVideoCameraWithError:(NSError **)error{
    AVCaptureDevice *camera = nil;
    
    for (camera in [TBMDeviceHandler allVideoCameras]){
        if (camera.position == AVCaptureDevicePositionFront) {
            break;
        }
    }
    
    if (!camera){
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Device has no front camera", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    DebugLog(@"TBMCameraHandler: Got available camera: %@", camera.localizedName);
    return camera;
}

+ (AVCaptureDeviceInput *)getInputWithDevice:(AVCaptureDevice *)device error:(NSError **)error{
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&*error];
    if (!input){
        return nil;
    }
    return input;
}

+ (NSArray *)allVideoCameras{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
}


// -----
// Audio
// -----
+ (AVCaptureDeviceInput *)getAudioInputWithError:(NSError * __autoreleasing *)error{
    AVCaptureDevice *device = [TBMDeviceHandler getAudioCaptureDevice];
    if (!device){
        return nil;
    }
    
    AVCaptureDeviceInput *input = [TBMDeviceHandler getInputWithDevice:device error:&*error];
    if (!input){
        DebugLog(@"ERROR: Could not get audio input");
        return nil;
    }
    DebugLog(@"Got audio input: %@", input);
    return input;
}

+ (AVCaptureDevice *)getAudioCaptureDevice{
    return (AVCaptureDevice *)[[TBMDeviceHandler allAudioDevices] firstObject];
}

+ (void)showAllAudioDevices{
    for (AVCaptureDevice *device in [TBMDeviceHandler allAudioDevices]){
        DebugLog(@"AudioDevice - %@", device.description);
    }
}

+ (NSArray *)allAudioDevices{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
}

@end
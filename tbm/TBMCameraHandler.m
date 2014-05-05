//
//  TBMCameraHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMCameraHandler.h"

@implementation TBMCameraHandler

+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError **)error
{
    AVCaptureDevice *device = [TBMCameraHandler getAvailableFrontVideoCameraWithError:&*error];
    if (!device){
        return nil;
    }
    AVCaptureDeviceInput *input = [TBMCameraHandler getInputWithDevice:device error:&*error];
    if (!input){
        return nil;
    }
    DebugLog(@"TBMCameraHandler: Got available input: %@", input);
    return input;
}

+ (AVCaptureDevice *)getAvailableFrontVideoCameraWithError:(NSError **)error
{
    AVCaptureDevice *camera = nil;
    
    for (camera in [TBMCameraHandler allVideoCameras]){
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

+ (NSArray *)allVideoCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
}

@end

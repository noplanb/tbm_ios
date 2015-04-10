//
//  TBMCameraHandler.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"


@interface TBMDeviceHandler : NSObject
+ (AVCaptureDeviceInput *) getAudioInputWithError:(NSError * __autoreleasing *)error;
+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError * __autoreleasing *)error;
@end

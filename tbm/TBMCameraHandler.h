//
//  TBMCameraHandler.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"


@interface TBMCameraHandler : NSObject
+ (AVCaptureDeviceInput *) getAvailableFrontVideoInputWithError:(NSError **)error;
@end

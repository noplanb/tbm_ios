//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

@interface TBMVideoRecorder : NSObject

@property UIView *previewView;
@property AVCaptureSession *captureSession;
@property AVCaptureInput *captureInput;

-(id)initWithPreivewView:(UIView *)previewView error:(NSError **)error;

@end

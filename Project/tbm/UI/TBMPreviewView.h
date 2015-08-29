//
//  TBMPreviewView.h
//  Zazo
//
//  Created by Kirill Kirikov on 08.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TBMPreviewView : UIView
- (void)showRecordingOverlay;
- (void)hideRecordingOverlay;
- (void)setupWithCaptureSession:(AVCaptureSession *)captureSession;
@end

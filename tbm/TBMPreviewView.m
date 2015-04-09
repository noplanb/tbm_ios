//
//  TBMPreviewView.m
//  Zazo
//
//  Created by Kirill Kirikov on 08.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMPreviewView.h"
#import "TBMSoundEffect.h"
#import "HexColor.h"
#import "TBMConfig.h"

static const float LayoutConstRecordingLabelHeight = 22;
static const float LayoutConstRecordingLabelFontSize = 0.55 * LayoutConstRecordingLabelHeight;
static NSString *LayoutConstRecordingLabelBackgroundColor = @"000";
static NSString *LayoutConstWhiteTextColor  = @"fff";
static const float LayoutConstRecordingBorderWidth = 2;

@interface TBMPreviewView()

@property CALayer *recordingOverlay;
@property TBMSoundEffect *dingSoundEffect;
@property UILabel *recordingLabel;

@end

@implementation TBMPreviewView

#pragma mark - Public

- (void)showRecordingOverlay {
    self.recordingOverlay.hidden = NO;
    self.recordingLabel.hidden = NO;
    
    [self playSoundEffect];
    [NSThread sleepForTimeInterval:0.4f];
}

- (void)hideRecordingOverlay {
    self.recordingOverlay.hidden = YES;
    self.recordingLabel.hidden = YES;
    
    [self playSoundEffect];
    [NSThread sleepForTimeInterval:0.1f];
}

- (void)setupWithCaptureSession:(AVCaptureSession *)captureSession {
    self.layer.sublayers = nil;
    [self connectVideoCaptureSession:captureSession];
    [self setupRecordingOverlay];
    [self setupSoundEffects];
}

#pragma mark - Private

- (void)playSoundEffect {
    [self.dingSoundEffect play];
}

- (void) connectVideoCaptureSession:(AVCaptureSession *)captureSession {
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    previewLayer.frame = self.layer.bounds;
    [self.layer addSublayer:previewLayer];
}

- (void) setupRecordingOverlay {
    [self addRedBorderAndDot];
    [self addRecordingLabel];
}

- (void) setupSoundEffects {
    self.dingSoundEffect = [[TBMSoundEffect alloc] initWithSoundNamed:CONFIG_DING_SOUND];
}

- (void)addRecordingLabel{
    float y = self.frame.size.height - LayoutConstRecordingLabelHeight;
    float width = self.frame.size.width - 2*LayoutConstRecordingBorderWidth;
    float height = LayoutConstRecordingLabelHeight - LayoutConstRecordingBorderWidth;
    self.recordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(LayoutConstRecordingBorderWidth, y, width, height)];
    self.recordingLabel.hidden = YES;
    self.recordingLabel.text = @"Recording";
    self.recordingLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstRecordingLabelBackgroundColor alpha:0.5];
    self.recordingLabel.textColor = [UIColor colorWithHexString:LayoutConstWhiteTextColor alpha:1];
    self.recordingLabel.textAlignment = NSTextAlignmentCenter;
    self.recordingLabel.font = [UIFont systemFontOfSize:LayoutConstRecordingLabelFontSize];
    [self addSubview:self.recordingLabel];
}

- (void)addRedBorderAndDot{
    self.recordingOverlay = [CALayer layer];
    self.recordingOverlay.hidden = YES;
    self.recordingOverlay.frame = self.bounds;
    self.recordingOverlay.cornerRadius = 2;
    self.recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
    self.recordingOverlay.borderWidth = LayoutConstRecordingBorderWidth;
    self.recordingOverlay.borderColor = [UIColor redColor].CGColor;
    self.recordingOverlay.delegate = self;
    [self.layer addSublayer:self.recordingOverlay];
    [self.recordingOverlay setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
}

- (void)addDotInContext:(CGContextRef)context{
    CGRect borderRect = CGRectMake(8, 8, 7, 7);
    CGContextSetRGBFillColor(context, 248, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

@end

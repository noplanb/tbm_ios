//
//  ZZGridBaseCell.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AVFoundation;

#import "ZZGridBaseCell.h"
#import "HexColors.h"

static CGFloat const kLayoutConstRecordingLabelHeight = 22;
static CGFloat const kLayoutConstRecordingLabelFontSize = 0.55 * kLayoutConstRecordingLabelHeight;
static NSString* kLayoutConstRecordingLabelBackgroundColor = @"000";
static NSString* kLayoutConstWhiteTextColor  = @"fff";
static CGFloat const kLayoutConstRecordingBorderWidth = 2;

@interface ZZGridBaseCell ()

@property (nonatomic, strong) CALayer *recordingOverlay;
@property (nonatomic, strong) UILabel *recordingLabel;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ZZGridBaseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setupRecordingOverlay];
    }
    return self;
}

- (void)showRecordingOverlay
{
    self.recordingOverlay.hidden = NO;
    self.recordingLabel.hidden = NO;
    [NSThread sleepForTimeInterval:0.4f];
}

- (void)hideRecordingOverlay
{
    self.recordingOverlay.hidden = YES;
    self.recordingLabel.hidden = YES;
    [NSThread sleepForTimeInterval:0.1f];
}

- (void)_setupRecordingOverlay
{
    [self _addRedBorderAndDot];
    [self recordingLabel];
}

- (UILabel *)recordingLabel
{
    if (!_recordingLabel)
    {
        _recordingLabel = [UILabel new];
        _recordingLabel.hidden = YES;
        _recordingLabel.text = NSLocalizedString(@"grid-controller.cell.record.title", nil);
        _recordingLabel.backgroundColor = [UIColor colorWithHexString:kLayoutConstRecordingLabelBackgroundColor alpha:0.5];
        _recordingLabel.textColor = [UIColor colorWithHexString:kLayoutConstWhiteTextColor alpha:1];
        _recordingLabel.textAlignment = NSTextAlignmentCenter;
        _recordingLabel.font = [UIFont systemFontOfSize:kLayoutConstRecordingLabelFontSize];
        [self addSubview:self.recordingLabel];
        
        [_recordingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(kLayoutConstRecordingLabelHeight - kLayoutConstRecordingBorderWidth));
        }];
    }
    
    return _recordingLabel;
}

- (void)_addRedBorderAndDot
{
    self.recordingOverlay = [CALayer layer];
    self.recordingOverlay.hidden = YES;
    self.recordingOverlay.frame = self.bounds;
    self.recordingOverlay.cornerRadius = 2;
    self.recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
    self.recordingOverlay.borderWidth = kLayoutConstRecordingBorderWidth;
    self.recordingOverlay.borderColor = [UIColor redColor].CGColor;
    self.recordingOverlay.zPosition = 100;
    [self.contentView.layer addSublayer:self.recordingOverlay];
    [self.recordingOverlay setNeedsDisplay];
}

- (UIView *)topView
{
    return nil;
}

@end

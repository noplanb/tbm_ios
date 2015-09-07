//
//  ZZGridCenterCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCell.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZVideoRecorder.h"
#import "UIImage+PDF.h"

static CGFloat const kLayoutConstRecordingLabelHeight = 22;
static CGFloat const kLayoutConstRecordingLabelFontSize = 0.55 * kLayoutConstRecordingLabelHeight;
static NSString* kLayoutConstRecordingLabelBackgroundColor = @"000";
static NSString* kLayoutConstWhiteTextColor  = @"fff";
static CGFloat const kLayoutConstRecordingBorderWidth = 2;

@interface ZZGridCenterCell ()

@property (nonatomic, strong) ZZGridCenterCellViewModel* model;
@property (nonatomic, strong) UIButton* switchCameraButton;
@property (nonatomic, strong) UIView* videoView;
@property (nonatomic, strong) CALayer *recordingOverlay;
@property (nonatomic, strong) UILabel *recordingLabel;

@end

@implementation ZZGridCenterCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setupRecordingOverlay];
        [self videoView];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCenterCellViewModel*)model
{
    self.model = model;
    self.switchCameraButton.hidden = [model shouldShowSwitchCameraButton];
    if (model.isRecording)
    {
        [self _showRecordingOverlay];
    }
    else
    {
        [self _hideRecordingOverlay];
    }
    model.recordView = self.videoView;
}


#pragma mark - Private

- (void)_switchCamera
{
    [self.model switchCamera];
}

- (void)_showRecordingOverlay
{
    self.recordingOverlay.hidden = NO;
    self.recordingLabel.hidden = NO;
    [NSThread sleepForTimeInterval:0.4f]; // TODO:
}

- (void)_hideRecordingOverlay
{
    self.recordingOverlay.hidden = YES;
    self.recordingLabel.hidden = YES;
    [NSThread sleepForTimeInterval:0.1f]; // TODO:
}

- (void)_setupRecordingOverlay
{
    [self _addRedBorderAndDot];
    [self recordingLabel];
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


#pragma mark - Lazy Load

- (UIView*)videoView
{
    if (!_videoView)
    {
        _videoView = [UIView new];
        [self.contentView addSubview:_videoView];
        
        [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _videoView;
}

- (UIButton*)switchCameraButton
{
    if (!_switchCameraButton)
    {
        _switchCameraButton = [UIButton new];
        CGSize imageSize = CGSizeMake(24, 21);
        UIImage* cameraImage = [[UIImage imageWithPDFNamed:@"home-camera-w-fill" atSize:imageSize]
                                an_imageByTintingWithColor:[UIColor colorWithWhite:0.9 alpha:0.8]];
        [_switchCameraButton setImage:cameraImage forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self
                                action:@selector(_switchCamera)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCameraButton];
        
        [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(40));
        }];
    }
    return _switchCameraButton;
}

- (UILabel*)recordingLabel
{
    if (!_recordingLabel)
    {
        _recordingLabel = [UILabel new];
        _recordingLabel.hidden = YES;
        _recordingLabel.text = NSLocalizedString(@"grid-controller.cell.record.title", nil);
        _recordingLabel.backgroundColor = [[UIColor an_colorWithHexString:kLayoutConstRecordingLabelBackgroundColor] colorWithAlphaComponent:0.5];
        _recordingLabel.textColor = [UIColor an_colorWithHexString:kLayoutConstWhiteTextColor];
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

@end

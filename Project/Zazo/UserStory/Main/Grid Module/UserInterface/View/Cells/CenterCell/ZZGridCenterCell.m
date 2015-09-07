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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.recordingOverlay.frame = self.contentView.bounds;
}

- (void)updateWithModel:(ZZGridCenterCellViewModel*)model
{
    self.model = model;
    ANDispatchBlockToMainQueue(^{
        self.switchCameraButton.hidden = ![model shouldShowSwitchCameraButton];
        if (model.isRecording)
        {
            [self _showRecordingOverlay];
        }
        else
        {
            [self _hideRecordingOverlay];
        }
        if (!self.videoView)
        {
            [self setupVideoViewWithView:model.recordView];
        }
    });
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

- (void)setupVideoViewWithView:(UIView*)view
{
    self.videoView = view;
    [self.contentView addSubview:view];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


#pragma mark - Lazy Load

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
        [self.contentView addSubview:_switchCameraButton];
        
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
        [self.contentView addSubview:self.recordingLabel];
        
        [_recordingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(kLayoutConstRecordingLabelHeight - kLayoutConstRecordingBorderWidth));
        }];
    }
    return _recordingLabel;
}

- (CALayer*)recordingOverlay
{
    if (!_recordingOverlay)
    {
        _recordingOverlay = [CALayer layer];
        _recordingOverlay.hidden = YES;
        _recordingOverlay.frame = self.bounds;
        _recordingOverlay.cornerRadius = 2;
        _recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
        _recordingOverlay.borderWidth = kLayoutConstRecordingBorderWidth;
        _recordingOverlay.borderColor = [UIColor redColor].CGColor;
        _recordingOverlay.zPosition = 100;
        [self.contentView.layer addSublayer:_recordingOverlay];
    }
    return _recordingOverlay;
}

@end

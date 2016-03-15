//
//  ZZGridCenterCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCell.h"
#import "ZZGridCenterCellViewModel.h"
#import "UIImage+PDF.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZRecordingView.h"

static CGFloat const kLayoutConstRecordingLabelHeight = 22;
static CGFloat const kLayoutConstRecordingLabelFontSize = 0.55 * kLayoutConstRecordingLabelHeight;
static NSString* kLayoutConstRecordingLabelBackgroundColor = @"000";
static NSString* kLayoutConstWhiteTextColor  = @"fff";
static CGFloat const kLayoutConstRecordingBorderWidth = 2.5;

@interface ZZGridCenterCell ()

@property (nonatomic, strong) ZZGridCenterCellViewModel* model;
@property (nonatomic, strong) UIView* recordingContainer;
@property (nonatomic, strong) UIView* videoView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) CALayer* recordingOverlay;
@property (nonatomic, strong) UIView* recordingView;

@end

@implementation ZZGridCenterCell

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.recordingOverlay.frame = self.bounds;
    self.previewLayer.frame = self.bounds;
}

- (void)updateWithModel:(ZZGridCenterCellViewModel*)model
{
    self.model = model;
    [self.model setupLongRecognizerOnView:self];
    ANDispatchBlockToMainQueue(^{
        self.switchCameraButton.hidden = ![model shouldShowSwitchCameraButton];
        if (!self.videoView)
        {
            self.videoView = model.recordView;
            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_switchCamera)];
            [self.videoView addGestureRecognizer:tapRecognizer];
            [self bringSubviewToFront:self.switchCameraButton];
        }
        if (!self.previewLayer)
        {
            self.previewLayer = model.previewLayer;
        }
    });
}


- (void)updataeRecordStateTo:(BOOL)isRecording
{
    if (isRecording)
    {
        [self _showRecordingOverlay];
    }
    else
    {
        [self _hideRecordingOverlay];
    }
}


#pragma mark - Private

- (void)_switchCamera
{
    [self.model switchCamera];
}

- (void)_showRecordingOverlay
{
    [self.recordingOverlay removeFromSuperlayer];
    self.recordingOverlay = nil;
    self.recordingOverlay.hidden = NO;
    self.recordingView.hidden = NO;
    self.switchCameraButton.hidden = YES;
}

- (void)_hideRecordingOverlay
{
    self.recordingOverlay.hidden = YES;
    self.recordingView.hidden = YES;
    self.switchCameraButton.hidden = ![self.model shouldShowSwitchCameraButton];
}

- (void)setVideoView:(UIView *)videoView
{
    if (_videoView != videoView)
    {
        [_videoView removeFromSuperview];
    }
    _videoView = videoView;
    [self.recordingContainer addSubview:_videoView];
    [self.recordingContainer sendSubviewToBack:_videoView];
    [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
{
    if (previewLayer == nil)
    {
        return;
    }
    if (self.videoView == nil)
    {
        ZZLogError(@"attempting to set previewLayer while videoView is nil. This should never happen.");
        return;
    }
    if (previewLayer != nil){
        _previewLayer = previewLayer;
        for (CALayer *layer in [self.videoView.layer.sublayers copy]) {
            [layer removeFromSuperlayer];
        }
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.videoView.layer addSublayer:_previewLayer];
    }
}

#pragma mark - Lazy Load

- (UIButton*)switchCameraButton
{
    if (!_switchCameraButton)
    {
        _switchCameraButton = [UIButton new];
        _switchCameraButton.userInteractionEnabled = NO;
        _switchCameraButton.hidden = ![ZZGridActionStoredSettings shared].frontCameraHintWasShown;
        [self addSubview:_switchCameraButton];
        [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(40));
        }];
        
        UIImageView* photoImage = [UIImageView new];
     
        UIImage* cameraImage = [UIImage imageNamed:@"icon_camera_switch"];
        photoImage.image = cameraImage;
        [_switchCameraButton addSubview:photoImage];
        [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(_switchCameraButton);
            make.width.equalTo(@(30));
            make.height.equalTo(@(30));
        }];
    }
    return _switchCameraButton;
}

- (UIView *)recordingContainer
{
    if (!_recordingContainer)
    {
        _recordingContainer = [UIView new];
        [self addSubview:_recordingContainer];
        [_recordingContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _recordingContainer;
}

- (UIView *)recordingView
{
    if (!_recordingView)
    {
        
        ZZRecordingView *recordingView =
        [[NSBundle mainBundle] loadNibNamed:@"ZZRecordingView"
                                      owner:nil
                                    options:nil].firstObject;
        
        recordingView.hidden = YES;
        [self.recordingContainer addSubview:recordingView];
        
        [recordingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.recordingContainer);
            make.top.equalTo(self.recordingContainer);            
        }];
        
        _recordingView = recordingView;
    }
    return _recordingView;
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
        [self.videoView.layer addSublayer:_recordingOverlay];
    }
    return _recordingOverlay;
}

@end

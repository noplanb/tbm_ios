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

@interface ZZGridCenterCell ()

@property (nonatomic, strong) ZZGridCenterCellViewModel* model;
@property (nonatomic, strong) UIButton* switchCameraButton;
@property (nonatomic, assign) BOOL isBackCamera;
@property (nonatomic, strong) UIView* videoView;
@property (nonatomic, assign) BOOL isChangeButtonAvailable;
@end

@implementation ZZGridCenterCell

- (void)updateWithModel:(id)model
{
    self.model = model;
    [[ZZVideoRecorder sharedInstance] updateViewGridCell:self];
   
    if ([[ZZVideoRecorder sharedInstance] isBothCamerasAvailable])
    {
        self.isChangeButtonAvailable = YES;
        [self videoView];
        [self switchCameraButton];
    }
}

- (UIView *)videoView
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

- (UIButton *)switchCameraButton
{
    if (!_switchCameraButton)
    {
        _switchCameraButton = [UIButton new];
        CGSize imageSize = CGSizeMake(24, 21);
        UIImage* cameraImage = [[UIImage imageWithPDFNamed:@"home-camera-w-fill" atSize:imageSize]
                                an_imageByTintingWithColor:[UIColor colorWithWhite:0.9 alpha:0.8]];
        [_switchCameraButton setImage:cameraImage forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self
                                action:@selector(switchCamera)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCameraButton];
        [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(40));
        }];
    }
    
    return _switchCameraButton;
}

- (void)switchCamera
{
    if (!self.isBackCamera)
    {
        [[ZZVideoRecorder sharedInstance] switchToBackCamera];
    }
    else
    {
        [[ZZVideoRecorder sharedInstance] switchToFrontCamera];
    }
    self.isBackCamera = !self.isBackCamera;
}

- (UIView *)topView
{
    return [self videoView];
}

- (void)showChangeCameraButton
{
    if (self.isChangeButtonAvailable)
    {
        self.switchCameraButton.hidden = NO;
    }

}

- (void)hideChangeCameraButton
{
    self.switchCameraButton.hidden = YES;
}

@end

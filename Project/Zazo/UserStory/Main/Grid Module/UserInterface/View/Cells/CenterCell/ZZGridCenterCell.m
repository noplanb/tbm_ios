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

@interface ZZGridCenterCell ()

@property (nonatomic, strong) ZZGridCenterCellViewModel* model;
@property (nonatomic, strong) UIButton* switchCameraButton;
@property (nonatomic, assign) BOOL isBackCamera;
@end

@implementation ZZGridCenterCell

- (void)updateWithModel:(id)model
{
    self.model = model;
    [[ZZVideoRecorder sharedInstance] updateViewGridCell:self];
   
    if ([[ZZVideoRecorder sharedInstance] isBothCamerasAvailable])
    {
        [self switchCameraButton];
    }
}

- (UIButton *)switchCameraButton
{
    if (!_switchCameraButton)
    {
        _switchCameraButton = [UIButton new];
        [_switchCameraButton setTitle:@"switch" forState:UIControlStateNormal];
        _switchCameraButton.backgroundColor = [UIColor grayColor];
        [_switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCameraButton];
        [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(30));
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

@end

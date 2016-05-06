//
//  ZZGridCenterCellModel.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//
@import AVFoundation;

@protocol ZZGridCenterCellViewModelDelegate <NSObject>

- (void)switchCamera;

- (void)showHint;

@end

@interface ZZGridCenterCellViewModel : NSObject

@property (nonatomic, assign) BOOL isChangeButtonAvailable;

@property (nonatomic, weak) id <ZZGridCenterCellViewModelDelegate> delegate;
@property (nonatomic, strong) UIView *recordView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


- (BOOL)shouldShowSwitchCameraButton;

- (void)switchCamera;

- (void)setupLongRecognizerOnView:(UIView *)view;

@end

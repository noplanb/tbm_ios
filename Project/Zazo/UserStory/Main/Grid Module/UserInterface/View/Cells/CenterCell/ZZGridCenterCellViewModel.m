//
//  ZZGridCenterCellModel.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCellViewModel.h"

@interface ZZGridCenterCellViewModel ()

@property (nonatomic, strong) UILongPressGestureRecognizer* longPressRecognizer;

@end

@implementation ZZGridCenterCellViewModel

- (void)switchCamera
{
    [self.delegate switchCamera];
}

- (BOOL)shouldShowSwitchCameraButton
{
    if (self.isRecording)
    {
        return NO;
    }
    return self.isChangeButtonAvailable;
}

- (UIView*)recordView
{
    if (!_recordView)
    {
        _recordView = [UIView new];
    }
    return _recordView;
}

- (void)setupLongRecognizerOnView:(UIView*)view
{
    [view addGestureRecognizer:self.longPressRecognizer];
}

- (UILongPressGestureRecognizer *)longPressRecognizer
{
    if (!_longPressRecognizer)
    {
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showHint:)];
        _longPressRecognizer.minimumPressDuration = 0.5;
    }
    
    return _longPressRecognizer;
}

- (void)showHint:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate showHint];
    }
}

@end

//
//  ZZGridCenterCellModel.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCenterCellViewModel.h"

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

@end

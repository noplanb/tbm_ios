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
        return YES;
    }
    return self.isChangeButtonAvailable;
}

@end

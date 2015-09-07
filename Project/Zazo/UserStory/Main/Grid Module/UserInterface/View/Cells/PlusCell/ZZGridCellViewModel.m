//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"

@implementation ZZGridCellViewModel

- (void)startRecordingWithView:(UIView *)view
{
    [self.delegate recordingStateUpdatedToState:YES viewModel:self];
}

- (void)stopRecording
{
    [self.delegate recordingStateUpdatedToState:NO viewModel:self];
    self.hasUploadedVideo = YES; // TODO:
}

- (void)nudgeSelected
{
    [self.delegate nudgeSelectedWithUserModel:self.item.relatedUser];
}

@end

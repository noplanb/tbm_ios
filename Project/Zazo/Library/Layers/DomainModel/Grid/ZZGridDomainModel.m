//
//  ZZGridDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDomainModel.h"

@implementation ZZGridDomainModel

- (void)startRecordingWithView:(UIView *)view
{
    [self.delegate startRecordingWithView:view];
}

- (void)stopRecording
{
    [self.delegate stopRecording];
}

- (void)nudgeSelected
{
    [self.delegate nudgeSelectedWithUserModel:self.relatedUser];
}

@end

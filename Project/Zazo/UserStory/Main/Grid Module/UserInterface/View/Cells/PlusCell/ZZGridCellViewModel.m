//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by Dmitriy Frolow on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"

@implementation ZZGridCellViewModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.domainModel = [ZZGridDomainModel new];
    }
    
    return self;
}

- (void)startRecordingWithView:(UIView *)view
{
    [self.delegate startRecordingWithView:view];
}

- (void)stopRecording
{
    [self.delegate stopRecording];
    self.badgeNumber = @(1); // TODO: only for test!!!
}

- (void)nudgeSelected
{
    [self.delegate nudgeSelectedWithUserModel:self.domainModel.relatedUser];
}

@end

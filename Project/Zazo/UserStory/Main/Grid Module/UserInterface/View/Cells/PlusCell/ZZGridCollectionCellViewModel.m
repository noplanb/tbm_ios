//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionCellViewModel.h"

@implementation ZZGridCollectionCellViewModel

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
    self.hasUploadedVideo = YES;
}

- (void)nudgeSelected
{
    [self.delegate nudgeSelectedWithUserModel:self.domainModel.relatedUser];
}


@end

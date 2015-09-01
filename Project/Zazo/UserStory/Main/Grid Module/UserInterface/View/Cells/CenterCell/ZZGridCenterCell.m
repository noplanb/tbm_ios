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

@end

@implementation ZZGridCenterCell

- (void)updateWithModel:(id)model
{
    self.model = model;
    [[ZZVideoRecorder sharedInstance] updateViewGridCell:self];
}

@end

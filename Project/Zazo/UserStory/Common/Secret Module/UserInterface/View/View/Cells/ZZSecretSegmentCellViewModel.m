//
//  ZZSecretSwitchServerCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSegmentCellViewModel.h"

@interface ZZSecretSegmentCellViewModel ()

@property (nonatomic, strong) NSArray *titles;

@end

@implementation ZZSecretSegmentCellViewModel

+ (instancetype)viewModelWithTitles:(NSArray *)titles
{
    ZZSecretSegmentCellViewModel *model = [self new];
    model.titles = titles;

    return model;
}

- (void)updateSelectedValueTo:(NSInteger)value
{
    self.selectedIndex = value;
    [self.delegate viewModel:self updatedSegmentValueTo:value];
}

@end

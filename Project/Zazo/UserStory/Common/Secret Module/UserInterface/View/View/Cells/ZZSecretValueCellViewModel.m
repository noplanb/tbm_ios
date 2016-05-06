//
//  ZZSecrectValueCellViewModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/31/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretValueCellViewModel.h"

@interface ZZSecretValueCellViewModel ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *details;

@end

@implementation ZZSecretValueCellViewModel

+ (instancetype)viewModelWithTitle:(NSString *)title details:(NSString *)details
{
    ZZSecretValueCellViewModel *model = [self new];
    model.title = title;
    model.details = details;

    return model;
}

@end

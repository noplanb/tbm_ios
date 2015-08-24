//
//  ANAppColorTheme.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANColorTheme.h"

@interface ANAppColorTheme : ANColorTheme

@property (nonatomic, strong) UIColor* baseCellTextColor;
@property (nonatomic, strong) UIColor* authBackgroundColor;

@property (nonatomic, strong) UIColor* menuBackgroundColor;
@property (nonatomic, strong) UIColor* menuTextColor;

+ (instancetype)shared;

@end

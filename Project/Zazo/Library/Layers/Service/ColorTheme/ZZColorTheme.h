//
//  ANAppColorTheme.h
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANColorTheme.h"

@interface ZZColorTheme : ANColorTheme

//TODO: move to category
@property (nonatomic, strong) UIColor* baseCellTextColor;
@property (nonatomic, strong) UIColor* authBackgroundColor;

@property (nonatomic, strong) UIColor* menuBackgroundColor;
@property (nonatomic, strong) UIColor* menuTextColor;

@property (nonatomic, strong) UIColor* gridBackgourndColor;
@property (nonatomic, strong) UIColor* gridHeaderBackgroundColor;
@property (nonatomic, strong) UIColor* gridMenuColor;
@property (nonatomic, strong) UIColor* gridMenuTextColor;

@property (nonatomic, strong) UIColor* secretScreenHeaderColor;
@property (nonatomic, strong) UIColor* secretScreenAddressBGGrayColor;
@property (nonatomic, strong) UIColor* secretScreenAddressBorderGrayColor;
@property (nonatomic, strong) UIColor* secretScreenBlueColor;

+ (instancetype)shared;

@end

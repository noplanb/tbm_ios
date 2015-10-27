//
//  ZZColorTheme.h
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

@property (nonatomic, strong) UIColor* gridCellLayoutGreenColor;
@property (nonatomic, strong) UIColor* gridCellGrayColor;
@property (nonatomic, strong) UIColor* gridCellTextColor;
@property (nonatomic, strong) UIColor* gridCellOrangeColor;
@property (nonatomic, strong) UIColor* gridCellPlusWhiteColor;
@property (nonatomic, strong) UIColor* gridCellUserNameGrayColor;

@property (nonatomic, strong) UIColor* gridStatusViewNudgeColor;
@property (nonatomic, strong) UIColor* gridStatusViewBlackColor;
@property (nonatomic, strong) UIColor* gridStatusViewRecordColor;
@property (nonatomic, strong) UIColor* gridStatusViewUserNameLabelColor;
@property (nonatomic, strong) UIColor* gridStatusViewThumbnailDefaultColor;
@property (nonatomic, strong) UIColor* gridStatusViewThumnailZColor;


@property (nonatomic, strong) UIColor* menuBackgroundColor;
@property (nonatomic, strong) UIColor* menuTextColor;
@property (nonatomic, strong) UIColor* menuTintColor;

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

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
@property (nonatomic, strong) UIColor* gridCellBorderColor;
@property (nonatomic, strong) UIColor* gridCellBackgroundColor;
@property (nonatomic, strong) UIColor* gridCellShadowColor;

@property (nonatomic, strong) UIColor* gridStatusViewNudgeColor;
@property (nonatomic, strong) UIColor* gridStatusViewBlackColor;
@property (nonatomic, strong) UIColor* gridStatusViewRecordColor;
@property (nonatomic, strong) UIColor* gridStatusViewThumbnailDefaultColor;
@property (nonatomic, strong) UIColor* gridStatusViewThumbnailColor;


@property (nonatomic, strong) UIColor* menuTintColor;

@property (nonatomic, strong) UIColor* gridBackgroundColor;
@property (nonatomic, strong) UIColor* gridMenuColor;

@property (nonatomic, strong) id <ANColorThemeButtonInterface> editFriendsTheme;

+ (instancetype)shared;

@end

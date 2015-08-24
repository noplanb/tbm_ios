//
//  ZZGrayBorderTextField.m
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGrayBorderTextField.h"

static NSInteger const kGBLeftContentPadding = 10;
static CGFloat const kLayerBorderWidth = 1.0;
static CGFloat const kLayerCornerRadius = 6.0;


@implementation ZZGrayBorderTextField

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [ANAppColorTheme shared].secretScreenAddressBGGrayColor;
        self.layer.borderWidth = kLayerBorderWidth;
        self.layer.cornerRadius = kLayerCornerRadius;
        self.layer.borderColor = [ANAppColorTheme shared].secretScreenAddressBorderGrayColor.CGColor;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x+=kGBLeftContentPadding;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x+=kGBLeftContentPadding;
    return bounds;
}


@end

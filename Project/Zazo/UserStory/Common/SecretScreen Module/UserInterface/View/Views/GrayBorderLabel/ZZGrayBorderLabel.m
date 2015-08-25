//
//  ZZGrayBorderLabel.m
//  Zazo
//
//  Created by ANODA on 23/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGrayBorderLabel.h"

static NSInteger const kGBLeftContentPadding = 5;
static CGFloat const kLayerBorderWidth = 1.0;
static CGFloat const kLayerCornerRadius = 6.0;

@implementation ZZGrayBorderLabel

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

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, kGBLeftContentPadding, 0, 0);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}



@end

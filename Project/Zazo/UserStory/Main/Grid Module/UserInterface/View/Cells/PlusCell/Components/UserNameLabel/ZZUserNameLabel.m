//
//  ZZUserNameLabel.m
//  Zazo
//
//  Created by ANODA on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserNameLabel.h"

@implementation ZZUserNameLabel


- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 2, 0, 2);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

//
//  ZZDateLabel.m
//  Zazo
//
//  Created by Rinat on 15/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZDateLabel.h"



@implementation ZZDateLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 4, 0, 4);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

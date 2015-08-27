//
//  TBMMarginLabel.m
//  tbm
//
//  Created by Sani Elfishawy on 1/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMMarginLabel.h"

@implementation TBMMarginLabel

- (void)drawRect:(CGRect)rect {
    UIEdgeInsets insets = {0, self.margin, 0, self.margin};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

//
//  ZZAuthTextField.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthTextField.h"

static CGFloat const kTextFieldCornerRadius = 5;
static CGFloat const KTextFieldBorderWidth = 1;
static CGFloat const kLeftPadding = 15;

@implementation ZZAuthTextField

- (instancetype)init
{
    if (self = [super init])
    {
        self.layer.cornerRadius = kTextFieldCornerRadius;
        self.layer.borderWidth = KTextFieldBorderWidth/([UIScreen mainScreen].scale);
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x+=kLeftPadding;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x+=kLeftPadding;
    return bounds;
}


- (void)updatePlaceholderWithText:(NSString *)placeholder
{
    if (!ANIsEmpty(placeholder))
    {
        self.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:placeholder
                                        attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                     NSFontAttributeName : [UIFont an_lightFontWithSize:18]
                                                     }];
    }
}

@end

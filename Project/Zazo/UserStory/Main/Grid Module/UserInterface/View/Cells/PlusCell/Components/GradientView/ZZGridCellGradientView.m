//
//  ZZGridCellGradientView.m
//  Zazo
//
//  Created by Rinat on 15/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZGridCellGradientView.h"

@implementation ZZGridCellGradientView
{
    CAGradientLayer *_layer;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _layer = [CAGradientLayer layer];
        _layer.colors =
        @[(id)[UIColor colorWithWhite:0 alpha:.5].CGColor,
          (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
          (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
          (id)[UIColor colorWithWhite:0 alpha:.5].CGColor,];
        
        _layer.locations = @[@0.0, @0.2, @0.8, @1.0];
        
        _layer.startPoint = CGPointZero;
        _layer.endPoint = CGPointMake(0, 1);
        
        [self.layer addSublayer:_layer];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _layer.frame = self.bounds;
    
    CGFloat height = 40.0f;
    CGFloat relativeHeight = height / _layer.frame.size.height;

    _layer.locations = @[@0.0, @(relativeHeight), @(1-relativeHeight), @1.0];
}

@end

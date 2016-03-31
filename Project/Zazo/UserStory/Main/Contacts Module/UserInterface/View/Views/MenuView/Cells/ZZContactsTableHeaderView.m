//
//  ZZContactsTableHeaderView.m
//  Zazo
//
//  Created by Rinat on 22/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZContactsTableHeaderView.h"

@interface ZZContactsTableHeaderView ()

@property (nonatomic, strong) CALayer *border;

@end

@implementation ZZContactsTableHeaderView

- (void)setup
{
    [super setup];
    self.bottomLabelInset = -35;
    self.titleLabel.font = [UIFont zz_regularFontWithSize:21];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (CALayer *)border
{
    if (!_border)
    {
        _border = [CALayer layer];
        _border.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        
        [self.layer addSublayer:_border];
    }
    
    return _border;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offset = 106;
    self.border.frame = CGRectMake(offset, 0, self.frame.size.width - offset, 1);
    self.titleLabel.width = 24;
}

@end

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
    self.bottomLabelInset = -40;
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

    CGFloat offset = 122;
    self.border.frame = CGRectMake(offset, 0, self.frame.size.width - offset, 1);
    self.titleLabel.width = 24;
}

- (void)updateWithModel:(NSString *)model
{
    if ([model isEqualToString:@"★"])
    {
        self.titleLabel.attributedText = [self _z];
    }
    else
    {
        self.titleLabel.text = [NSLocalizedString(model, nil) uppercaseString];
    }
}

- (NSAttributedString *)_z
{
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:@"z.png"];

    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:textAttachment];

    return string;
}

@end

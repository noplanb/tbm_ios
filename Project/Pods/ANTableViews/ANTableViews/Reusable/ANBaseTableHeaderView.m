//
//  ANBaseTableHeaderFooterView.m
//
//  Created by Oksana Kovalchuk on 4/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANBaseTableHeaderView.h"
#import "UIColor+ANAdditions.h"
#import "UIFont+ANAdditions.h"
#import "UILabel+ANAdditions.h"

static CGFloat const kANLabelSmallOffset = 10.0f;

@interface ANBaseTableHeaderView ()

@end

@implementation ANBaseTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.yLabelOffset = 15;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    CGFloat height = [self.titleLabel an_textContentSizeConstrainedToWidth:size.width].height;
    CGFloat yOffset = size.height - kANLabelSmallOffset - height + 5.0f;
    self.titleLabel.frame = CGRectMake(self.yLabelOffset, yOffset, size.width - kANLabelSmallOffset * 2.0f, height);
}

- (void)updateWithModel:(NSString*)model
{
    self.titleLabel.text = [NSLocalizedString(model, nil) uppercaseString];
}

/**
 * We use custom label, because changing frame of system label will cause -layoutSubviews method
 */
#pragma mark - Views

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor an_colorWithHexString:@"4d4d4d"];
        _titleLabel.font = [UIFont an_regularFontWithSize:15];
        _titleLabel.clipsToBounds = NO;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end

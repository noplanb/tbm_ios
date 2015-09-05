
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//
#import "ZZFakeRotationCell.h"

static CGFloat const kVideoCountLabelWidth = 23;

@interface ZZFakeRotationCell ()

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel* badgeLabel;

@end

@implementation ZZFakeRotationCell

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self stateImageView];
        [self badgeLabel];
    }
    return self;
}

- (void)setLabel:(NSString*)label
{
    _label = label;
    self.numberLabel.text = label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.numberLabel.frame = self.bounds;
}

- (void)tapped
{
    NSLog(@"%@ Tapped", self.label);
}

- (void)longTapStarted
{
    NSLog(@"%@ Long Tap Started", self.label);
}

- (void)longTapEnded {
    NSLog(@"Long Tap Ended");
}

- (void)updateBadgeWithNumber:(NSNumber*)number
{
    if (number)
    {
        self.badgeLabel.hidden = NO;
        self.badgeLabel.text = [NSString stringWithFormat:@"%@",number];
    }
}


#pragma mark - Lazy Load

- (UILabel*)numberLabel
{
    if (!_numberLabel)
    {
        _numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        UIColor *orangeColor = [UIColor colorWithRed:0.957 green:0.541 blue:0.192 alpha:1];
        _numberLabel.textColor = orangeColor;
        _numberLabel.font = [UIFont systemFontOfSize:25];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
        [self bringSubviewToFront:_numberLabel];
    }
    
    return _numberLabel;
}

- (UIImageView*)stateImageView
{
    if (!_stateImageView)
    {
        _stateImageView = [UIImageView new];
        [self addSubview:_stateImageView];
        
        [_stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _stateImageView;
}

- (UILabel*)badgeLabel
{
    if (!_badgeLabel)
    {
        _badgeLabel = [UILabel new];
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.layer.cornerRadius = kVideoCountLabelWidth/2;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.hidden = YES;
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        [self.stateImageView addSubview:_badgeLabel];
        
        [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.stateImageView).with.offset(3);
            make.top.equalTo(self.stateImageView).with.offset(-3);
            make.height.equalTo(@(kVideoCountLabelWidth));
            make.width.equalTo(@(kVideoCountLabelWidth));
        }];
    }
    return _badgeLabel;
}

@end
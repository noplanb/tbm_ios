//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import "Cell.h"

@interface Cell ()
@property(nonatomic, strong) UILabel *numberLabel;
@end

@implementation Cell {

}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self stateImageView];
    }
    return self;
}

- (void)setLabel:(NSString *)label {
    _label = label;
    self.numberLabel.text = label;
}

- (void)layoutSubviews {
    self.numberLabel.frame = self.bounds;
}

- (void)tapped {
    NSLog(@"%@ Tapped", self.label);
}

- (void)longTapStarted {
    NSLog(@"%@ Long Tap Started", self.label);
}

- (void)longTapEnded {
    NSLog(@"Long Tap Ended");
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
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

- (UIImageView *)stateImageView
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

@end
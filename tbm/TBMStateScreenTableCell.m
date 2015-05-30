//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenTableCell.h"

@interface TBMStateScreenTableCell ()
@property(nonatomic, strong) UILabel *topLabel;
@property(nonatomic, strong) UILabel *bottomLabel;
@end

@implementation TBMStateScreenTableCell {

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    self.contentView.backgroundColor = [UIColor clearColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.topLabel];
    [self.contentView addSubview:self.bottomLabel];

    NSLog(@"LABEL %@", NSStringFromCGRect(self.topLabel.frame));

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupDisplay];
}

- (void)setupDisplay {
    CGRect bounds = self.contentView.bounds;
    CGRect topFrame = CGRectMake(
            CGRectGetMinX(bounds) + leftInset, CGRectGetMinY(bounds) + verticalMargin,
            CGRectGetWidth(bounds) - leftInset, topLabelHeight + (verticalMargin * 2));
    self.topLabel.frame = topFrame;

    CGRect bottomFrame = CGRectMake(
            CGRectGetMinX(bounds) + leftInset, CGRectGetMaxY(topFrame) + verticalMargin,
            CGRectGetWidth(bounds) - leftInset, bottomLabelHeight + (verticalMargin * 2));
    self.bottomLabel.frame = bottomFrame;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topLabel.backgroundColor = [UIColor whiteColor];
        _topLabel.textColor = [UIColor blackColor];
        _topLabel.font = [UIFont systemFontOfSize:13];
        _topLabel.numberOfLines = 0;
        _topLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _topLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _topLabel;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bottomLabel.backgroundColor = [UIColor whiteColor];
        _bottomLabel.textColor = [UIColor darkGrayColor];
        _bottomLabel.font = [UIFont systemFontOfSize:10];
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _bottomLabel;
}


- (void)setMainText:(NSString *)mainText {
    _mainText = mainText;
    self.topLabel.text = mainText;
}

- (void)setAdditionalText:(NSString *)additionalText {
    _additionalText = additionalText;
    self.bottomLabel.text = additionalText;
}


@end
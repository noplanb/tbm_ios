//
// Created by Rinat on 01/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZAddContactButton.h"


@implementation ZZAddContactButton {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor;
        self.adjustsImageWhenHighlighted = NO;
        self.showsTouchWhenHighlighted = NO;
        self.reversesTitleShadowWhenHighlighted = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);

        [self _makeLayout];

    }

    return self;
}

- (void)_makeLayout
{
    UIView *borderView = [UIView new];
    borderView.userInteractionEnabled = NO;
    borderView.layer.borderWidth = 2;
    borderView.layer.borderColor = [ZZColorTheme shared].gridCellBorderColor.CGColor;

    [self addSubview:borderView];

    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(3, 3, 3, 3));
    }];
}

- (void)setIsActive:(BOOL)isActive {
    _isActive = isActive;

    NSString *imageName = isActive ? @"contact-button-pink" : @"contact-button-gray";
    UIImage *image = [UIImage imageNamed:imageName];

    [self setImage:image forState:UIControlStateNormal];

    self.imageEdgeInsets =     // shadow compensation
    isActive ? UIEdgeInsetsMake(-8, -8, -16, -8) : UIEdgeInsetsZero;
}

@end
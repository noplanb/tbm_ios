//
//  ZZHintsGotItView.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsGotItView.h"

@interface ZZHintsGotItView ()

@property (nonatomic, strong) UIImageView *gotItImage;
@property (nonatomic, strong) UILabel *gotItLabel;

@end

@implementation ZZHintsGotItView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self gotItImage];
    }
    return self;
}

- (void)updateWithType:(ZZHintsBottomImageType)imageType
{
    UIImage *currentImage;

    switch (imageType)
    {

        case ZZHintsBottomImageTypePresent:
        {
            currentImage = [UIImage imageNamed:@"present-icon"];
        }
            break;

        case ZZHintsBottomImageTypeGotIt:
        {
            currentImage = [UIImage imageNamed:@"circle-white"];
            self.gotItLabel.text = @"Got it";
        }
            break;

        case ZZHintsBottomImageTypeTryItNow:
        {
            currentImage = [UIImage imageNamed:@"circle-white"];
            self.gotItLabel.text = @"Try it now";
        }
            break;

        default:
            break;
    }

    self.gotItImage.image = currentImage;
}

#pragma mark - Lazy Load

- (UIImageView *)gotItImage
{
    if (!_gotItImage)
    {
        _gotItImage = [UIImageView new];
        [self addSubview:_gotItImage];

        [_gotItImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _gotItImage;
}

- (UILabel *)gotItLabel
{
    if (!_gotItLabel)
    {
        _gotItLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _gotItLabel.font = [UIFont fontWithName:kZZTutorialFontName size:25];
        _gotItLabel.textColor = [UIColor whiteColor];
        _gotItLabel.textColor = [UIColor whiteColor];
        _gotItLabel.textAlignment = NSTextAlignmentCenter;
        _gotItLabel.minimumScaleFactor = .7f;
        _gotItLabel.numberOfLines = 0;
        [self addSubview:_gotItLabel];

        [_gotItLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _gotItLabel;
}

@end

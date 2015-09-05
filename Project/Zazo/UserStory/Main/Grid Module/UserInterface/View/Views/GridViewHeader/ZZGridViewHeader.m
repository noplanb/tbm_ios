//
//  ZZGridViewHeader.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#pragma mark  - Title Image

static CGFloat const kTileImageLeftPadding = 12;
static CGFloat const kTitleImageBottomPadding = 18;

#pragma mark  - Menu Button

static CGFloat const kMenuButtonRightPadding = 55;
static CGFloat const kButtonSize = 44;

#import "ZZGridViewHeader.h"
#import "UIImage+PDF.h"

@interface ZZGridViewHeader ()

@end

@implementation ZZGridViewHeader

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self titleImageView];
        [self menuButton];
        [self editFriendsButton];
    }
    return self;
}

- (UIImageView*)titleImageView
{
    if (!_titleImageView)
    {
        _titleImageView = [UIImageView new];
        _titleImageView.image = [[UIImage imageWithPDFNamed:@"app_logo" atHeight:19]
                                 an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        _titleImageView.contentMode = UIViewContentModeCenter;
        [_titleImageView sizeToFit];
        [self addSubview:_titleImageView];
        
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(@(kTileImageLeftPadding));
            make.bottom.equalTo(@(kTitleImageBottomPadding));
        }];
    }
    return _titleImageView;
}

- (UIButton *)menuButton
{
    if (!_menuButton)
    {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* menuImage = [[UIImage imageWithPDFNamed:@"icon_people" atHeight:15]
                              an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        [_menuButton setImage:menuImage forState:UIControlStateNormal];
        [self addSubview:_menuButton];
        
        [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kButtonSize));
            make.height.equalTo(@(kButtonSize));
            make.right.equalTo(self).with.offset(-kMenuButtonRightPadding);
            make.bottom.equalTo(self);
        }];
    }
    return _menuButton;
}

- (UIButton*)editFriendsButton
{
    if (!_editFriendsButton)
    {
        _editFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* menuImage = [[UIImage imageWithPDFNamed:@"icon_dots" atHeight:19]
                              an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        [_editFriendsButton setImage:menuImage forState:UIControlStateNormal];
        [self addSubview:_editFriendsButton];
        
        [_editFriendsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.width.equalTo(@(kButtonSize));
            make.height.equalTo(@(kButtonSize));
        }];
    }
    
    return _editFriendsButton;
}

@end

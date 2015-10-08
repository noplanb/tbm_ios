//
//  ZZGridViewHeader.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#pragma mark  - Title Image

static CGFloat const kTileImageLeftPadding = 10;

#pragma mark  - Menu Button

static CGFloat const kMenuButtonRightPadding = 55;
static CGFloat const kButtonSize = 44;

#import "ZZGridViewHeader.h"
#import "UIImage+PDF.h"
#import "ZZGridUIConstants.h"

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
        _titleImageView.image = [[UIImage imageWithPDFNamed:@"app_logo" atHeight:22]
                                 an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        _titleImageView.contentMode = UIViewContentModeCenter;
        [_titleImageView sizeToFit];
        [self addSubview:_titleImageView];
        
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(@(kTileImageLeftPadding));
        }];
    }
    return _titleImageView;
}

- (UIButton*)menuButton
{
    if (!_menuButton)
    {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* menuImage = [[UIImage imageWithPDFNamed:@"icon_people" atHeight:20]
                              an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        [_menuButton setImage:menuImage forState:UIControlStateNormal];
        [self addSubview:_menuButton];
        
        [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kEditFriendsButtonWidth));
            make.right.equalTo(self).with.offset(-kMenuButtonRightPadding);
            make.bottom.top.equalTo(self);
        }];
    }
    return _menuButton;
}

- (UIButton*)editFriendsButton
{
    if (!_editFriendsButton)
    {
        _editFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* menuImage = [[UIImage imageWithPDFNamed:@"icon_dots" atHeight:20]
                              an_imageByTintingWithColor:[ZZColorTheme shared].menuTintColor];
        [_editFriendsButton setImage:menuImage forState:UIControlStateNormal];
        [self addSubview:_editFriendsButton];
        
        [_editFriendsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.right.equalTo(self);
            make.width.equalTo(@(kButtonSize));
        }];
    }
    
    return _editFriendsButton;
}

@end

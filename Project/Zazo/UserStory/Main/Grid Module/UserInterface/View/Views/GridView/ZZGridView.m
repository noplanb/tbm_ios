//
//  ZZGridView.m
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridView.h"
#import "ZZGridCollectionLayout.h"
#import "ZZGridCollectionCell.h"

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)

#pragma mark - Header height
static CGFloat const kHeaderViewHeight = 64;

#pragma mark  - Title Image
static CGFloat const kTileImageLeftPadding = 5;

#pragma mark  - Menu Button
static CGFloat const kMenuButtonRightPadding = 5;


@interface ZZGridView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <ZZGridViewDelegate> delegate;

@end

@implementation ZZGridView

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
        [self headerView];
        [self titleImageView];
        [self menuButton];
        [self collectionView];
        [self configureRecognizers];
    }
    return self;
}

- (UIView *)headerView
{
    if (!_headerView)
    {
        _headerView = [UIView new];
        _headerView.backgroundColor = [ZZColorTheme shared].gridHeaderBackgroundColor;
        [self addSubview:_headerView];
        
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(kHeaderViewHeight)).priorityHigh();
        }];
    }
    return _headerView;
}

- (UIImageView *)titleImageView
{
    if (!_titleImageView)
    {
        _titleImageView = [UIImageView new];
        _titleImageView.image = [UIImage imageNamed:@"zazo-type-1x"];
        _titleImageView.contentMode = UIViewContentModeCenter;
        [_titleImageView sizeToFit];
        [self.headerView addSubview:_titleImageView];
        
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView);
            make.centerY.equalTo(self.headerView.mas_centerY);
            make.left.equalTo(@(kTileImageLeftPadding));
        }];
    }
    
    return _titleImageView;
}

- (UIButton *)menuButton
{
    if (!_menuButton)
    {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuButton setImage:[UIImage imageNamed:@"icon-drawer-1x"] forState:UIControlStateNormal];
        [self.headerView addSubview:_menuButton];
        
        [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.headerView).with.offset(-kMenuButtonRightPadding);
            make.centerY.equalTo(self.headerView.mas_centerY);
        }];
    }
    
    return _menuButton;
}

- (UIButton *)editFriendsButton
{
    if (!_editFriendsButton)
    {
        _editFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editFriendsButton setImage:[UIImage imageNamed:@"icon-drawer-1x"] forState:UIControlStateNormal];
        [self.headerView addSubview:_editFriendsButton];
        
        [_editFriendsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.menuButton.mas_left).with.offset(-kMenuButtonRightPadding);
            make.centerY.equalTo(self.headerView.mas_centerY);
        }];
    }
    return _editFriendsButton;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        ZZGridCollectionLayout* collectionLayout = [ZZGridCollectionLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = NO;
        
         __block CGFloat height;
        
        if (IS_IPHONE_4)
        {
            height = 416;
        }
        else if (IS_IPHONE_5)
        {
            height = 447.5;
        }
        else if (IS_IPHONE_6)
        {
            height = 522;
        }
        else if (IS_IPHONE_6_PLUS)
        {
            height = 579;
        }
        
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(@(height));
        }];
    }
    return _collectionView;
}

- (void)updateWithDelegate:(id<ZZGridViewDelegate>)delegate
{
    if (delegate)
    {
        self.delegate = delegate;
        [self configureRecognizers];
    }
}

- (void)configureRecognizers {
    self.rotationRecognizer = [[RotationGestureRecognizer alloc] initWithTarget:self.delegate
                                                                         action:@selector(handleRotationGesture:)];
  
    self.rotationRecognizer.delegate = self.delegate;
    [self addGestureRecognizer:self.rotationRecognizer];
}

@end

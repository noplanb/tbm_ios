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

@interface ZZGridView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <ZZGridViewDelegate> delegate;

@end

@implementation ZZGridView

- (instancetype)init
{
    if (self = [super init])
    {
        [self headerView];
        [self collectionView];
        [self configureRecognizers];
        
        self.headerView.menuButton.rac_command = [RACCommand commandWithBlock:^{
            [self.eventDelegate menuSelected];
        }];
        
        self.headerView.editFriendsButton.rac_command = [RACCommand commandWithBlock:^{
            [self.eventDelegate editFriendsSelected];
        }];
        [self enableViewRotation];
    }
    
    return self;
}


#pragma mark - Header  View

- (ZZGridViewHeader *)headerView
{
    if (!_headerView)
    {
        _headerView = [ZZGridViewHeader new];
        _headerView.backgroundColor = [ZZColorTheme shared].gridHeaderBackgroundColor;
        [self addSubview:_headerView];
        
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(kHeaderViewHeight)).priorityHigh();
        }];
    }
    return _headerView;
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
        else if (IS_IPAD)
        {
            height = 1021;
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

- (void)disableViewRotation
{
    self.isRotationEnabled = NO;
}

- (void)enableViewRotation
{
    self.isRotationEnabled = YES;
}

@end

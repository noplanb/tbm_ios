//
//  ZZGridView.m
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridView.h"
#import "ZZGridUIConstants.h"
#import "ZZGridCenterCell.h"

@interface ZZGridView ()

@end

@implementation ZZGridView

- (instancetype)init
{
    if (self = [super init])
    {
        [self headerView];
        [self itemsContainerView];
        
        self.isRotationEnabled = YES;
        
        self.maxCellsOffset = (CGFloat) (M_PI * 2);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.delegate updatedFrame:self.bounds];
}

- (void)setCalculatedCellsOffset:(CGFloat)calculatedCellsOffset
{
    _calculatedCellsOffset = calculatedCellsOffset;
    while (_calculatedCellsOffset >= self.maxCellsOffset)
    {
        _calculatedCellsOffset -= self.maxCellsOffset;
    }
    while (_calculatedCellsOffset <= 0)
    {
        _calculatedCellsOffset += self.maxCellsOffset;
    }
    [self.delegate placeCells];
}

- (NSArray *)items
{
    return self.itemsContainerView.items;
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
            make.height.equalTo(@(kGridHeaderViewHeight)).priorityHigh();
        }];
    }
    return _headerView;
}

- (ZZGridContainerView*)itemsContainerView
{
    if (!_itemsContainerView)
    {
        _itemsContainerView = [[ZZGridContainerView alloc] initWithSegementsCount:9];
        _itemsContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_itemsContainerView];
        CGFloat topPadding;
        if (!IS_IPAD)
        {
            topPadding = (CGRectGetHeight([UIScreen mainScreen].bounds) - kGridHeight() - kGridHeaderViewHeight)/2;
        }
        else
        {
            topPadding = (CGRectGetHeight([UIScreen mainScreen].bounds) - kGridHeight());
        }
        [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom).with.offset(topPadding);
            make.left.right.equalTo(self);
            make.height.equalTo(@(kGridHeight()));
        }];
    }
    return _itemsContainerView;
}

@end

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


@implementation ZZGridView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

        ZZSetGridSize([self _containerSizeWithViewSize:frame.size]);

        [self itemsContainerView];

        self.isRotationEnabled = YES;
        self.maxCellsOffset = (CGFloat)(M_PI * 2);

    }
    return self;
}

- (CGSize)_containerSizeWithViewSize:(CGSize)size
{
    return CGSizeMake(size.width - [self _leftInset] - [self _rightInset], size.height - [self _topInset] - [self _bottomInset]);
}

- (CGFloat)_topInset
{
    return kGridItemSpacing();
}

- (CGFloat)_leftInset
{
    return kGridItemSpacing();
}

- (CGFloat)_rightInset
{
    return kGridItemSpacing();
}

- (CGFloat)_bottomInset
{
    return 3 * kGridItemSpacing();
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

- (ZZGridContainerView *)itemsContainerView
{
    if (!_itemsContainerView)
    {
        _itemsContainerView = [[ZZGridContainerView alloc] initWithSegmentsCount:9];
        _itemsContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_itemsContainerView];
        [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset([self _topInset]);
            make.bottom.equalTo(self).offset([self _bottomInset]);
            make.left.equalTo(self).offset([self _leftInset]);
            make.right.equalTo(self).offset(-[self _rightInset]);
        }];
    }
    return _itemsContainerView;
}

@end

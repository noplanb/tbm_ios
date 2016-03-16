//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZTabbarView.h"


@implementation ZZTabbarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 66);
}

- (void)setItems:(NSArray <id<ZZTabbarViewItem>> *)items
{
    _items = [items copy];

    [self.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView *subview, NSUInteger idx, BOOL *stop) {
        [self removeArrangedSubview:subview];
    }];

    [items enumerateObjectsUsingBlock:^(id<ZZTabbarViewItem> item, NSUInteger idx, BOOL *stop) {
        UIView *view = [self _viewFromItem:item];
        [self addArrangedSubview:view];
    }];
}

- (UIView *)_viewFromItem:(id<ZZTabbarViewItem>)item
{
    UIImageView *view = [[UIImageView alloc] initWithImage:item.tabbarViewItemImage];
    view.contentMode = UIViewContentModeCenter;
    return view;
}


@end
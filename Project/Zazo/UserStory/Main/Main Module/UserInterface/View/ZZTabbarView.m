//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZTabbarView.h"


@interface ZZTabbarView ()

@end


@implementation ZZTabbarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.distribution = OAStackViewDistributionFillEqually;

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
    UIImage *image = nil;

    if ([(NSObject *)item respondsToSelector:@selector(tabbarViewItemImage)])
    {
        image = item.tabbarViewItemImage;
    }
    else
    {
        image = [UIImage imageNamed:@"icon-drawer"];
    }

    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIButton *button = [[UIButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(tapOnButton:)
     forControlEvents:UIControlEventTouchUpInside];

    button.tintColor = [UIColor grayColor];

    button.contentMode = UIViewContentModeCenter;
    return button;
}

- (void)tapOnButton:(UIButton *)button
{
    NSUInteger index = [self.arrangedSubviews indexOfObject:button];

    if (index == NSNotFound)
    {
        return;
    }

    [self.delegate tabbarView:self didTapOnItemWithIndex:index];
}

- (void)setActiveItemIndex:(NSUInteger)activeItemIndex
{
    UIButton *previousActiveButton = self.arrangedSubviews[_activeItemIndex];
    previousActiveButton.tintColor = [UIColor grayColor];

    _activeItemIndex = activeItemIndex;

    UIButton *actualActiveButton = self.arrangedSubviews[_activeItemIndex];
    actualActiveButton.tintColor = self.window.tintColor;
}


@end
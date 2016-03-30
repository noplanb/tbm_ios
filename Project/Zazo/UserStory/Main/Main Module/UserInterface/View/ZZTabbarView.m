//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZTabbarView.h"
#import <OAStackView.h>

@interface ZZTabbarView ()

@property (nonatomic, strong, readonly) OAStackView *stackView;

@end


@implementation ZZTabbarView

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self _makeStackView];

        CALayer *layer = self.layer;
        layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
        layer.shadowRadius = 1.0f;
        layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        layer.shadowOpacity = 1.0f;


    }

    return self;
}

- (void)_makeStackView
{
    _stackView = [OAStackView new];
    [self addSubview:self.stackView];
    
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        
    }];

    self.stackView.distribution = OAStackViewDistributionFillEqually;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 60);
}

- (void)setItems:(NSArray <id<ZZTabbarViewItem>> *)items
{
    _items = [items copy];

    [self.stackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView *subview, NSUInteger idx, BOOL *stop) {
        [self.stackView removeArrangedSubview:subview];
    }];

    [items enumerateObjectsUsingBlock:^(id<ZZTabbarViewItem> item, NSUInteger idx, BOOL *stop) {
        UIView *view = [self _viewFromItem:item];
        [self.stackView addArrangedSubview:view];
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
    button.backgroundColor = [UIColor whiteColor];
    
    button.contentMode = UIViewContentModeCenter;
    return button;
}

- (void)tapOnButton:(UIButton *)button
{
    NSUInteger index = [self.stackView.arrangedSubviews indexOfObject:button];

    if (index == NSNotFound)
    {
        return;
    }

    [self.delegate tabbarView:self didTapOnItemWithIndex:index];
}

- (void)setActiveItemIndex:(NSUInteger)activeItemIndex
{
    UIButton *previousActiveButton = self.stackView.arrangedSubviews[_activeItemIndex];
    previousActiveButton.tintColor = [UIColor grayColor];

    _activeItemIndex = activeItemIndex;

    UIButton *actualActiveButton = self.stackView.arrangedSubviews[_activeItemIndex];
    actualActiveButton.tintColor = self.window.tintColor;
}

@end
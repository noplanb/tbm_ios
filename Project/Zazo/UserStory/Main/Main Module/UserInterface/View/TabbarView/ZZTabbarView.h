//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZTabbarView;

@protocol ZZTabbarViewItem

@property (nonatomic, strong) UIImage *tabbarViewItemImage;

@optional
- (void)tabbarItemDidAppear;

@end


@protocol ZZTabbarViewDelegate

- (void)tabbarView:(ZZTabbarView *)tabbarView didTapOnItemWithIndex:(NSUInteger)index;

@end


@interface ZZTabbarView : UIView

@property (nonatomic, copy) NSArray <id<ZZTabbarViewItem>> *items;
@property (nonatomic, weak) id<ZZTabbarViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger activeItemIndex;

@property (nonatomic, weak) UISlider *progressView;

@property (nonatomic, assign) NSUInteger progressViewBadge;

@end
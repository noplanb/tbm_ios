//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

CGFloat const ZZTabbarViewHeight = 60;

@class ZZTabbarView;

@protocol ZZTabbarViewItem

@property (nonatomic, strong) UIImage *tabbarViewItemImage;

@optional
- (void)tabbarItemDidAppear;
- (void)tabbarItemDidDisappear;

@end


@protocol ZZTabbarViewDelegate

- (void)tabbarView:(ZZTabbarView *)tabbarView didTapOnItemWithIndex:(NSUInteger)index;

@end


@interface ZZTabbarView : UIView

@property (nonatomic, copy) NSArray <id <ZZTabbarViewItem>> *items;
@property (nonatomic, weak) id <ZZTabbarViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger activeItemIndex;


@end
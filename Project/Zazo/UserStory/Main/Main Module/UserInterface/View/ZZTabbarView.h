//
// Created by Rinat on 16/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAStackView.h"

@protocol ZZTabbarViewItem

@property (nonatomic, strong) UIImage *tabbarViewItemImage;

@end

@interface ZZTabbarView : OAStackView

@property (nonatomic, copy) NSArray <id<ZZTabbarViewItem>> *items;

@end
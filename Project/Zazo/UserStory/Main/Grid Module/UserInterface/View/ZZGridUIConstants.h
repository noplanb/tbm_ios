//
//  ZZGridUIConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/7/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import CoreGraphics;
@import UIKit;

#import "ANDefines.h"

static inline CGFloat const kGridItemSpacing();

CGSize ZZGridItemSize;

static inline void ZZSetGridSize(CGSize size)
{
    NSUInteger ZZRowCount = 3;
    NSUInteger ZZColumnCount = 3;

    CGFloat spacing = kGridItemSpacing();
    CGFloat height = (size.height - spacing * (ZZRowCount - 1)) / ZZRowCount;
    CGFloat width = (size.width - spacing * (ZZColumnCount - 1)) / ZZColumnCount;

    ZZGridItemSize = CGSizeMake(width, height);
}

static inline CGSize const kGridItemSize()
{
    return ZZGridItemSize;
}

static inline CGFloat const kGridItemSpacing()
{
    if (IS_IPHONE_4)
    {
        return 6;
    }
    else if (IS_IPHONE_5)
    {
        return 6;
    }
    else if (IS_IPHONE_6)
    {
        return 6.5;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        return 6.5;
    }
    else if (IS_IPAD)
    {
        return 6.5;
    }
    return 0;
}

static inline CGFloat const kGridHeight()
{
    CGFloat height;

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
    return height;
}


static CGFloat const kLayoutConstNameLabelHeight = 33;
static CGFloat const kLayoutConstDateLabelFontSize = 12;

static UIEdgeInsets const kGridSectionInsets = {12, 12, 12, 12};

static CGFloat const kSidePadding = 2;
static CGFloat const kUserNameScaleValue = 5;
static CGFloat const kLayoutConstIndicatorMaxWidth = 40;
static CGFloat const kLayoutConstIndicatorFractionalWidth = 0.15;
static CGFloat const kDownloadBarHeight = 2;
static CGFloat const kVideoCountLabelWidth = 24;

static CGFloat const kContainFriendAnimationDuration = 0.20;
static CGFloat const kContainFreindDelayDuration = 0.16;


static inline NSArray *const kGridElementsIndexes()
{
    return @[@(7), @(6), @(4), @(5), @(0), @(3), @(1), @(2)];
}


static inline NSInteger const kNextGridElementIndexFromFlowIndex(NSInteger count)
{
//    7 6 4
//    5 c 0
//    3 1 2
    NSArray *array = kGridElementsIndexes();
    if (count < array.count)
    {
        return [[array objectAtIndex:count] integerValue];
    }
    return NSNotFound;
}

static inline NSInteger const kGridIndexFromFlowIndex(NSInteger count)
{
    NSArray *array = kGridElementsIndexes();
    return [array indexOfObject:@(count)];
}


#pragma mark - Hints

static inline NSArray *const kHintsGridElementsIndexes()
{
    return @[@(7), @(6), @(4), @(5), @(8), @(0), @(3), @(1), @(2)];
}

static inline NSInteger const kHintNextGridElementIndexFromFlowIndex(NSInteger count)
{
    NSArray *array = kHintsGridElementsIndexes();
    if (count < array.count)
    {
        return [[array objectAtIndex:count] integerValue];
    }
    return NSNotFound;
}

static inline NSInteger const kHintGridIndexFromFlowIndex(NSInteger count)
{
    NSArray *array = kHintsGridElementsIndexes();
    return [array indexOfObject:@(count)];
}


#pragma mark - Reverse convertation

static inline NSArray *const kReverseGridIndexes()
{
    return @[@(5), @(7), @(8), @(6), @(2), @(3), @(1), @(0)];
}

static inline NSInteger const kReverseIndexConvertation(NSInteger index)
{
    NSArray *array = kReverseGridIndexes();
    return [array indexOfObject:@(index)];
}




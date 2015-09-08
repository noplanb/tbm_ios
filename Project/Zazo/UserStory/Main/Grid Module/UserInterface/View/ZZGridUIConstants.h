//
//  ZZGridUIConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/7/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)

static inline CGSize const kGridItemSize()
{
    if (IS_IPHONE_4)
    {
        return CGSizeMake(96, 128);
    }
    else if (IS_IPHONE_5)
    {
        return CGSizeMake(96, 137.5);
    }
    else if (IS_IPHONE_6)
    {
        return CGSizeMake(114, 163);
    }
    else if (IS_IPHONE_6_PLUS)
    {
        return CGSizeMake(127,182);
    }
    else if (IS_IPAD)
    {
        return CGSizeMake(245, 308);
    }
    return CGSizeZero;
}

static inline CGFloat const kGridItemSpacing()
{
    if (IS_IPHONE_4)
    {
        return 4;
    }
    else if (IS_IPHONE_5)
    {
        return 4;
    }
    else if (IS_IPHONE_6)
    {
        return 4.5;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        return 4.5;
    }
    else if (IS_IPAD)
    {
        return 4.5;
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


static UIEdgeInsets const kGridSectionInsets = {12, 12, 12, 12};
static CGFloat const kGridHeaderViewHeight = 64;

static CGFloat const kSidePadding = 2;
static CGFloat const kUserNameScaleValue = 5;
static CGFloat const kLayoutConstIndicatorMaxWidth = 40;
static CGFloat const kLayoutConstIndicatorFractionalWidth = 0.15;
static CGFloat const kDownloadBarHeight = 2;
static CGFloat const kVideoCountLabelWidth = 23;

static CGFloat const kContainFriendAnimationDuration = 0.20;
static CGFloat const kContainFreindDelayDuration = 0.16;



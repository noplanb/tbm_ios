//
//  ZZSecretScreenViewSizes.h
//  Zazo
//
//  Created by ANODA on 23/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#pragma mark - Info Label sizes

static inline CGFloat const secretLabelInfoHeight()
{
    return (CGRectGetHeight([UIScreen mainScreen].bounds)/17)*5;
}

static inline CGFloat labelHeight()
{
    return CGRectGetHeight([UIScreen mainScreen].bounds)/17;
}

static inline CGFloat labelLeftPadding()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/22;
}

static inline CGFloat serverAddressTextFieldHeigh()
{
    return CGRectGetHeight([UIScreen mainScreen].bounds)/15;
}

#pragma mark - Server Segment Controll

static inline CGFloat segmentControllTopPadding()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/24;
}

static inline CGFloat segmentControllHeight()
{
    return CGRectGetHeight([UIScreen mainScreen].bounds)/15;
}


#pragma mark - Debug Label/Switch

static inline CGFloat debugModeLabelTopPadding()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/21;
}

static inline CGFloat debugSwitchTopPadding()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/26;
}


#pragma mark - Button View

static inline CGFloat secretButtonHeight()
{
    return CGRectGetHeight([UIScreen mainScreen].bounds)/15;
}

static inline CGFloat secretButtonWidth()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/2.4;
}

static inline CGFloat secretButtonPadding()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds)/24;
}

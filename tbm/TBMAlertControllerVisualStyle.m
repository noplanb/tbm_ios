//
//  TBMAlertControllerVisualStyle.m
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertControllerVisualStyle.h"
#import "SDCAlertController.h"

@implementation TBMAlertControllerVisualStyle

#pragma mark - Alert

- (UIEdgeInsets)contentPadding {
    return UIEdgeInsetsMake(44, 30, 12, 30);
}

- (CGFloat)cornerRadius {
    return 14;
}

#pragma mark - Title & Message Labels

- (UIFont *)titleLabelFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:21.0f];
}

- (UIFont *)messageLabelFont {
    return [UIFont fontWithName:@"Helvetica-Light" size:15.0f];
}

- (CGFloat)labelSpacing {
    return 64;
}

- (CGFloat)messageLabelBottomSpacing {
    return 24;
}

#pragma mark - Actions

- (CGFloat)actionViewHeight {
    return 70;
}

- (UIColor *)actionViewSeparatorColor {
    return [UIColor colorWithRed:0.53f green:0.51f blue:0.48f alpha:1.0f];
}

- (UIColor *)textColorForAction:(SDCAlertAction *)action {
    return [UIColor colorWithRed:0.18f green:0.18f blue:0.16f alpha:1.0f];
    // if (action.style == SDCAlertActionStyleDestructive)
}

- (UIFont *)fontForAction:(SDCAlertAction *)action {
    if (action.style == SDCAlertActionStyleCancel) {
        return [UIFont fontWithName:@"Helvetica" size:20.0f];
    } else {
        return [UIFont fontWithName:@"Helvetica-Light" size:20.0f];
    }
}

#pragma mark - Text Fields

- (UIFont *)textFieldFont {
    return [UIFont systemFontOfSize:13];
}

- (CGFloat)estimatedTextFieldHeight {
    return 25;
}

- (CGFloat)textFieldBorderWidth {
    return 1 / [UIScreen mainScreen].scale;
}

- (UIColor *)textFieldBorderColor {
    return [UIColor colorWithRed:64.f/255 green:64.f/255 blue:64.f/255 alpha:1];
}

- (UIEdgeInsets)textFieldMargins {
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

@end
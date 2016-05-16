//
//  ZZPlayerBackgroundView.m
//  Zazo
//
//  Created by Rinat on 16/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZPlayerBackgroundView.h"

@implementation ZZPlayerBackgroundView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (!view || view == self) // pass touches to grid if tapped on background
    {
        return [self.presentingView hitTest:point withEvent:event];
    }
    
    return view;
}

@end

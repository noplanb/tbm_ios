//
//  ZZHintArrowConfigurationModel.m
//  Zazo
//
//  Created by ANODA on 10/6/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintArrowConfigurationModel.h"

static CGFloat const kAnimationViewWidth = 20.0;

@interface ZZHintArrowConfigurationModel ()

@property (nonatomic, assign) CGRect focusFrame;
@property (nonatomic, assign) ZZHintsType type;

@end

@implementation ZZHintArrowConfigurationModel

+ (instancetype)configureWithFocusPosition:(ZZHintArrowFocusPosition)focusPosition
                            arrowDirection:(ZZArrowDirection)direction
                                     angle:(CGFloat)angle
                                focusFrame:(CGRect)focusFrame
                                  itemType:(ZZHintsType)type
{
    ZZHintArrowConfigurationModel* configurationModel = [ZZHintArrowConfigurationModel new];
    configurationModel.focusPosition = focusPosition;
    configurationModel.arrowDirection = direction;
    configurationModel.angle = angle;
    configurationModel.focusFrame = focusFrame;
    configurationModel.type = type;
    return configurationModel;
}

- (CGPoint)focusPoint
{
    CGPoint focusPoint;
    
    if (self.type == ZZHintsTypeSentHint || self.type == ZZHintsTypeViewedHint)
    {
        focusPoint = [self _focusPointSentAndViewed];
    }
    else
    {
        focusPoint = [self _focusPointForShowCell];
    }
    
    
    return focusPoint;
}

- (CGPoint)_focusPointSentAndViewed
{
 
    CGPoint point = CGPointZero;
    
    switch (self.focusPosition)
    {
        case ZZHintArrowFocusPositionTopLeft:
        {
            point = CGPointMake((CGRectGetMaxX(self.focusFrame) - kAnimationViewWidth), CGRectGetMinY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionTopRight:
        {
            point = CGPointMake(CGRectGetMaxX(self.focusFrame), CGRectGetMinY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionBottomLeft:
        {
            point = CGPointMake((CGRectGetMaxX(self.focusFrame) - kAnimationViewWidth), (CGRectGetMinY(self.focusFrame) + kAnimationViewWidth));
        } break;
        case ZZHintArrowFocusPositionBottomRight:
        {
            point = CGPointMake(CGRectGetMaxX(self.focusFrame), (CGRectGetMinY(self.focusFrame) + kAnimationViewWidth));
        } break;
        default:
        {
            point = CGPointZero;
        } break;
    }
    
    return point;

    
}

- (CGPoint)_focusPointForShowCell
{
    CGPoint point = CGPointZero;
    
    switch (self.focusPosition)
    {
        case ZZHintArrowFocusPositionTopLeft:
        {
            point = CGPointMake(CGRectGetMinX(self.focusFrame), CGRectGetMinY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionTopRight:
        {
            point = CGPointMake(CGRectGetMaxX(self.focusFrame), CGRectGetMinY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionBottomLeft:
        {
            point = CGPointMake(CGRectGetMinX(self.focusFrame), CGRectGetMaxY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionBottomRight:
        {
            point = CGPointMake(CGRectGetMaxX(self.focusFrame), CGRectGetMaxY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionMiddleLeft:
        {
            point = CGPointMake(CGRectGetMinX(self.focusFrame), CGRectGetMidY(self.focusFrame));
        } break;
        case ZZHintArrowFocusPositionMiddleRight:
        {
            point = CGPointMake(CGRectGetMaxX(self.focusFrame), CGRectGetMidY(self.focusFrame));
        } break;
        default:
        {
            point = CGPointZero;
        } break;
    }
    
    return point;
}

@end

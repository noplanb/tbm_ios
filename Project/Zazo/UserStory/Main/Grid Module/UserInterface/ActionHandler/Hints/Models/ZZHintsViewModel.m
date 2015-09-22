//
//  ZZHintsViewModel.m
//  Zazo
//
//  Created by Oleg Panforov on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"

@interface ZZHintsViewModel ()

@property (nonatomic, strong) ZZHintsDomainModel* item;
@property (nonatomic, assign) CGRect focusFrame;
@property (nonatomic, assign) CGPoint arrowFocusPoint;

@end

@implementation ZZHintsViewModel

+ (instancetype)viewModelWithItem:(ZZHintsDomainModel*)item
{
    ZZHintsViewModel* model = [self new];
    model.item = item;
    
    return model;
}

- (void)updateFocusFrame:(CGRect)focusFrame
{
    self.focusFrame = focusFrame;
}

- (CGPoint)generateArrowFocusPoint
{
    switch (self.item.type)
    {
        case ZZHintsTypeSendZazo:
        case ZZHintsTypePressAndHoldToRecord:
        {
            return CGPointMake(CGRectGetMinX(self.focusFrame),
                                CGRectGetMinY(self.focusFrame));
            
        } break;
            
        case ZZHintsTypeZazoSent:
        {
            return CGPointMake(CGRectGetMaxX(self.focusFrame) - 20.f,
                               CGRectGetMinY(self.focusFrame));
            
        } break;
            
        case ZZHintsTypeGiftIsWaiting:
        {
            return CGPointMake(CGRectGetMinX(self.focusFrame),
                               CGRectGetMidY(self.focusFrame) + (CGRectGetHeight(self.focusFrame) / 4));
            
        } break;
            
        default: break;
    }

    return CGPointZero;
}

- (BOOL)hidesArrow
{
    return self.item.hidesArrow;
}

- (CGFloat)arrowAngle
{
    return self.item.angle;
}

- (ZZArrowDirection)arrowDirection
{
    return self.item.arrowDirection;
}

- (NSString*)text
{
    return self.item.title;
}

- (ZZHintsBottomImageType)bottomImageType
{
    return self.item.imageType;
}


@end

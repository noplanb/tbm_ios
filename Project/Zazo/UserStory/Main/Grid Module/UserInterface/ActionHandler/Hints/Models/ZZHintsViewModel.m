//
//  ZZHintsViewModel.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
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
        case ZZHintsTypeWelcomeFor:
        case ZZHintsTypeAbortRecording:
        case ZZHintsTypeEarpieceUsage:
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
        case ZZHintsTypeEditFriends:
        {
            return CGPointMake(CGRectGetMinX(self.focusFrame),
                               CGRectGetMidY(self.focusFrame) + (CGRectGetHeight(self.focusFrame) / 4));
            
        } break;
            
        case ZZHintsTypeTapToSwitchCamera:
        case ZZHintsTypeWelcomeNudgeUser:
        {
            return CGPointMake(CGRectGetMaxX(self.focusFrame),
                               CGRectGetMidY(self.focusFrame));
        } break;
        
        case ZZHintsTypeSpin:
        {
            return CGPointMake(CGRectGetMaxX(self.focusFrame),
                               CGRectGetMinY(self.focusFrame));
            
        } break;
            
            
        default: break;
    }

    return CGPointZero;
}

- (CGPoint)generateArrowFocusPointForIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
        case 1:
        case 3:
        case 6:
        case 7:
        {
            return CGPointMake(CGRectGetMaxX(self.focusFrame),
                               CGRectGetMidY(self.focusFrame));
        } break;
            
        case 2:
        case 8:
        {
            return CGPointMake(CGRectGetMinX(self.focusFrame),
                               CGRectGetMidY(self.focusFrame));
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

- (CGFloat)arrowAngleForIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
        case 1:
        {
            return 120.0f;
        } break;
            
        case 2:
        {
            return -120.f;
        } break;
            
        case 3:
        {
            return 45;
        } break;
        
        case 6:
        case 7:
        {
            return 30;
        } break;
            
        case 8:
        {
            return -60;
        } break;
            
        default: break;
    }
    
    return 0;
}


- (ZZArrowDirection)arrowDirection
{
    return self.item.arrowDirection;
}

- (NSString*)text
{
    if (self.item.formatParameter)
    {
        NSString* fulltext = [NSString stringWithFormat:NSLocalizedString(self.item.title, @""), self.item.formatParameter];
        return fulltext;
    }
    else
    {
        return self.item.title;
    }
}

- (ZZHintsBottomImageType)bottomImageType
{
    return self.item.imageType;
}


@end

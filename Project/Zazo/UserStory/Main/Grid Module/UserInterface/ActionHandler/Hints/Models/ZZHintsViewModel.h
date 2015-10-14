//
//  ZZHintsViewModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@class ZZHintsDomainModel;

typedef NS_ENUM(NSInteger, ZZHintPresentationState)
{
    ZZHintPresentationStateInactive,
    ZZHintPresentationStateActive,
    ZZHintPresentationStatePresented
};

@interface ZZHintsViewModel : NSObject

+ (instancetype)viewModelWithItem:(ZZHintsDomainModel*)item;

- (void)updateFocusFrame:(CGRect)focusFrame;

- (NSString*)text;
- (CGRect)focusFrame;

- (CGPoint)generateArrowFocusPointForIndex:(NSInteger)index;

- (CGFloat)arrowAngle;
- (CGFloat)arrowAngleForIndex:(NSInteger)index;

- (ZZArrowDirection)arrowDirection;
- (ZZArrowDirection)arrowDirectionForIndex:(NSInteger)index;

- (BOOL)hidesArrow;
- (ZZHintsBottomImageType)bottomImageType;
- (ZZHintsType)hintType;

@end

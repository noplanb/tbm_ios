//
//  ZZHintsViewModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@class ZZHintsDomainModel;

@interface ZZHintsViewModel : NSObject

+ (instancetype)viewModelWithItem:(ZZHintsDomainModel*)item;

- (void)updateFocusFrame:(CGRect)focusFrame;

- (NSString*)text;
- (CGRect)focusFrame;
- (CGPoint)generateArrowFocusPoint;
- (ZZArrowDirection)arrowDirection;
- (CGFloat)arrowAngle;
- (BOOL)hidesArrow;
- (ZZHintsBottomImageType)bottomImageType;


@end

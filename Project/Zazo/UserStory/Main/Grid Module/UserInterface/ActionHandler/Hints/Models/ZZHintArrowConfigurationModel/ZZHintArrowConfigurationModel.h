//
//  ZZHintArrowConfigurationModel.h
//  Zazo
//
//  Created by ANODA on 10/6/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@interface ZZHintArrowConfigurationModel : NSObject

+ (instancetype)configureWithFocusPosition:(ZZHintArrowFocusPosition)focusPosition
                            arrowDirection:(ZZArrowDirection)direction
                                     angle:(CGFloat)angle
                                focusFrame:(CGRect)focusFrame
                                  itemType:(ZZHintsType)type;

@property (nonatomic,assign) ZZHintArrowFocusPosition focusPosition;
@property (nonatomic, assign) ZZArrowDirection arrowDirection;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGPoint focusPoint;

@end

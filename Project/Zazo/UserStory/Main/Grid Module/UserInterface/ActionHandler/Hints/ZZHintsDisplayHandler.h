//
//  ZZHintsDisplayHandler.h
//  Zazo
//
//  Created by Oleg Panforov on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@class TBMHintArrow;

@interface ZZHintsDisplayHandler : NSObject

+ (TBMHintArrow *)arrowWithText:(NSString *)text directionType:(ZZArrowDirection)direction focusFrame:(CGRect)focusFrame displayType:(ZZHintsDisplayType)displayType fromFrame:(CGRect)frame;

@end

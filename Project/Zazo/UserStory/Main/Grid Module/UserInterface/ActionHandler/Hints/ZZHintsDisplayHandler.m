//
//  ZZHintsDisplayHandler.m
//  Zazo
//
//  Created by Oleg Panforov on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsDisplayHandler.h"
#import "TBMHintArrow.h"

@implementation ZZHintsDisplayHandler

+ (TBMHintArrow *)arrowWithText:(NSString *)text directionType:(ZZArrowDirection)direction focusFrame:(CGRect)focusFrame displayType:(ZZHintsDisplayType)displayType fromFrame:(CGRect)frame
{
    TBMHintArrow *arrowView;
    
    switch (displayType) {
        case ZZHintsDisplayTypeGridCell:
        {
            
        } break;
            
        case ZZHintsDisplayTypePlain:
        {
        } break;
            
        case ZZHintsDisplayTypeCustom:
        {
        } break;
        
        default: break;
    }
    
//    [TBMHintArrow arrowWithText:NSLocalizedString(@"hints.send-a-zazo.label.text", nil)
//                      curveKind:TBMTutorialArrowCurveKindRight
//                     arrowPoint:CGPointMake(CGRectGetMinX(highlightFrame),
//                                            CGRectGetMidY(highlightFrame))
//                          angle:-40.f
//                         hidden:NO
//                          frame:self.frame];
    
    return arrowView;
}

@end

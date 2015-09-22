//
//  ZZArrowDirectionHelper.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZArrowDirectionHelper.h"

@implementation ZZArrowDirectionHelper

+ (ZZArrowDirection)arrowDirectionForGridViewWithIndex:(NSInteger)index
{
    ZZArrowDirection direction;
    
    switch (index)
    {
        case 0:
        case 1:
        case 3:
        case 4:
        case 6:
        case 7:
            direction = ZZArrowDirectionLeft;
        break;
            
        default:
            direction = ZZArrowDirectionRight;
        break;
    }
    
    return direction;
}

@end

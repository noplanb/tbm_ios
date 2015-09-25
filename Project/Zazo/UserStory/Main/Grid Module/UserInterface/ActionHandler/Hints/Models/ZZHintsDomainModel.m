//
//  ZZHintsDomainModel.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsDomainModel.h"
#import "ZZGridActionDataProvider.h"

@implementation ZZHintsDomainModel

- (void)toggleStateTo:(BOOL)state
{
    [ZZGridActionDataProvider saveHintState:state forHintType:self.type];
}

+ (ZZArrowDirection)arrowDirectionForIndex:(NSInteger)index
{
    ZZArrowDirection direction;

    switch (index)
    {
        case 0:
        case 1:
        case 8:
            direction = ZZArrowDirectionRight;
            break;

        case 2:
        case 3:
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

//
//  TBMGeometryUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGeometryUtils.h"

@implementation TBMGeometryUtils

+ (float)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    float x2 = powf(p1.x - p2.x, 2);
    float y2 = powf(p1.y - p2.y, 2);
    return powf(x2 + y2, 0.5);
}

@end

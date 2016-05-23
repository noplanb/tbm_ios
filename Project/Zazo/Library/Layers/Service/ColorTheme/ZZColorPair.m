//
//  ZZColorPair.m
//  Zazo
//
//  Created by Rinat on 23/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZColorPair.h"

@implementation ZZColorPair

+ (instancetype)randomPair
{
    NSUInteger number = arc4random_uniform(3);

    return [self colorWithThemeNumber:number];
}

+ (instancetype)colorWithThemeNumber:(NSUInteger)themeNumber
{
    
    ZZColorPair *pair = [ZZColorPair new];
    ZZColorTheme *theme = [ZZColorTheme shared];
    
    switch (themeNumber)
    {
        case 0:
            pair.tintColor = theme.gridCellTintColor1;
            pair.backgroundColor = theme.gridCellBackgroundColor1;
            break;
        case 1:
            pair.tintColor = theme.gridCellTintColor2;
            pair.backgroundColor = theme.gridCellBackgroundColor2;
            break;
        case 2:
            pair.tintColor = theme.gridCellTintColor3;
            pair.backgroundColor = theme.gridCellBackgroundColor3;
            break;
            
        default:
            break;
    }
    
    return pair;
}

+ (instancetype)colorForUsername:(NSString *)username;
{
    if (ANIsEmpty(username))
    {
        return [self colorWithThemeNumber:arc4random_uniform(3)];
    }
    
    return [self colorWithThemeNumber:username.length % 3];
}

@end

//
// Created by Rinat on 02/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "UIFont+ZZAdditions.h"


@implementation UIFont (ZZAdditions)

+ (UIFont *)zz_lightFontWithSize:(CGFloat)size
{
    if (SYSTEM_VERSION < 8.2)
    {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    }

    return [UIFont systemFontOfSize:size weight:300];
}

+ (UIFont *)zz_regularFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)zz_mediumFontWithSize:(CGFloat)size
{
    if (SYSTEM_VERSION < 8.2)
    {
        return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
    }

    return [UIFont systemFontOfSize:size weight:500];

}

+ (UIFont *)zz_boldFontWithSize:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)zz_condensedBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:size];
}

@end
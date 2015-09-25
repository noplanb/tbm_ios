//
//  UIImage+ANDefault.m
//  Zazo
//
//  Created by ANODA on 3/7/15.
//  Copyright (c) 2015 Oksana Kovalchuk. All rights reserved.
//

#import "UIImage+ANDefault.h"

#define IOS9_OR_HIGHER          (9.0 <= SYSTEM_VERSION)

static NSString* const kDefaultIphone6 = @"LaunchImage-800-667h@2x.png";
static NSString* const kDefaultIphone6Plus = @"LaunchImage-800-Portrait-736h@3x.png";
static NSString* const kDefaultIphone5 = @"LaunchImage-700-568h";
static NSString* const kDefaultIphone4 = @"LaunchImage-700";

static NSString* const kDefaultIphone6iOS9 = @"LaunchImageFinal-800-667h@2x.png";
static NSString* const kDefaultIphone6PlusiOS9 = @"LaunchImageFinal-800-Portrait-736h@3x.png";
static NSString* const kDefaultIphone5iOS9 = @"LaunchImageFinal-700-568h";
static NSString* const kDefaultIphone4iOS9 = @"LaunchImageFinal-700";


@implementation UIImage (ANDefault)

+ (UIImage*)an_defaultImage
{
    UIImage* result;
    
    if (IOS9_OR_HIGHER)
    {
        if (IS_IPHONE_6)
        {
            result = [UIImage imageNamed:kDefaultIphone6iOS9];
        }
        else if (IS_IPHONE_6_PLUS)
        {
            result = [UIImage imageNamed:kDefaultIphone6PlusiOS9];
        }
        else if (IS_IPHONE_5)
        {
            result = [UIImage imageNamed:kDefaultIphone5iOS9];
        }
        else
        {
            result = [UIImage imageNamed:kDefaultIphone4iOS9];
        }
    }
    else
    {
        if (IS_IPHONE_6)
        {
            result = [UIImage imageNamed:kDefaultIphone6];
        }
        else if (IS_IPHONE_6_PLUS)
        {
            result = [UIImage imageNamed:kDefaultIphone6Plus];
        }
        else if (IS_IPHONE_5)
        {
            result = [UIImage imageNamed:kDefaultIphone5];
        }
        else
        {
            result = [UIImage imageNamed:kDefaultIphone4];
        }

    }
    
    return result;
}

@end

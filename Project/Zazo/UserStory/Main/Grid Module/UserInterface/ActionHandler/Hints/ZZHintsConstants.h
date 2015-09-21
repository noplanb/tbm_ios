//
//  ZZHintsConstants.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZHintsType)
{
    ZZHintsTypeSendZazo = 0,
    ZZHintsTypePressAndHoldToRecord,
    ZZHintsTypeZazoSent,
    ZZHintsTypeGiftIsWaiting,
};

typedef NS_ENUM(NSInteger, ZZArrowDirection)
{
    ZZArrowDirectionLeft = 0,
    ZZArrowDirectionRight,
};

typedef NS_ENUM(NSInteger, ZZHintsDisplayType)
{
    ZZHintsDisplayTypeGridCell = 0,
    ZZHintsDisplayTypePlain,
    ZZHintsDisplayTypeCustom,
};



@interface ZZHintsConstants : NSObject

@end

//
//  ZZHintsConstants.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

typedef NS_ENUM(NSInteger, ZZHintsType)
{
    ZZHintsTypeNoHint = 0,
    ZZHintsTypeSendZazo,
    ZZHintsTypeTapToPlay,
    ZZHintsTypePressAndHoldToRecord,
    ZZHintsTypeZazoSent,
    ZZHintsTypeGiftIsWaiting,
    ZZHintsTypeTapToSwitchCamera,
    ZZHintsTypeWelcomeNudgeUser,
    ZZHintsTypeWelcomeFor,
    ZZHintsTypeAbortRecording,
    ZZHintsTypeEditFriends,
    ZZHintsTypeEarpieceUsage,
    ZZHintsTypeSpin,
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

typedef NS_ENUM(NSInteger, ZZHintsBottomImageType)
{
    ZZHintsBottomImageTypeNone = 0,
    ZZHintsBottomImageTypePresent,
    ZZHintsBottomImageTypeGotIt,
    ZZHintsBottomImageTypeTryItNow,
};

NSString *const kZZTutorialFontName;


@interface ZZHintsConstants : NSObject

@end

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
    ZZHintsTypeInviteHint,
    ZZHintsTypePlayHint,
    ZZHintsTypeRecrodWelcomeHint,
    ZZHintsTypeRecordHint,
    ZZHintsTypeSentHint,
    ZZHintsTypeViewedHint,
    ZZHintsTypeInviteSomeElseHint,
    ZZHintsTypeSendWelcomeHint,
    ZZHintsTypeSendWelcomeHintForFriendWithoutApp,
    ZZHintsTypeFrontCameraUsageHint,
    ZZHintsTypeAbortRecordingUsageHint,
    ZZHintsTypeDeleteFriendUsageHint,
    ZZHintsTypeEarpieceUsageHint,
    ZZHintsTypeSpinUsageHint,
    ZZHintsTypeGiftIsWaiting,
    ZZHintsTypeWelcomeNudgeUser,
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


typedef NS_ENUM(NSInteger,ZZHintArrowFocusPosition)
{
    ZZHintArrowFocusPositionTopLeft,
    ZZHintArrowFocusPositionTopRight,
    ZZHintArrowFocusPositionBottomLeft,
    ZZHintArrowFocusPositionBottomRight,
    ZZHintArrowFocusPositionMiddleLeft,
    ZZHintArrowFocusPositionMiddleRight
};



@interface ZZHintsConstants : NSObject

@end

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
    ZZHintsTypeFullscreenUsageHint,
    ZZHintsTypePlaybackControlsUsageHint,
    ZZHintsTypeEarpieceUsageHint,
    ZZHintsTypeSpinUsageHint,
    ZZHintsTypeGiftIsWaiting,
    ZZHintsTypeWelcomeNudgeUser,
    ZZHintsTypeRecordAndTapToPlay
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


typedef NS_ENUM(NSInteger, ZZHintArrowFocusPosition)
{
    ZZHintArrowFocusPositionTopLeft,
    ZZHintArrowFocusPositionTopRight,
    ZZHintArrowFocusPositionBottomLeft,
    ZZHintArrowFocusPositionBottomRight,
    ZZHintArrowFocusPositionMiddleLeft,
    ZZHintArrowFocusPositionMiddleRight
};

static inline NSInteger kHintArrowLabelFontSize()
{
    NSInteger fontSize = 30;

    if (IS_IPAD)
    {
        fontSize = 70;
    }

    return fontSize;
}

static inline ZZHintArrowFocusPosition kMiddleTopArrowFocusPositionDependsOnDevice()
{
    ZZHintArrowFocusPosition focusPosition = ZZHintArrowFocusPositionMiddleRight;

    if (IS_IPAD)
    {
        focusPosition = ZZHintArrowFocusPositionBottomRight;
    }

    return focusPosition;
}

static inline ZZHintArrowFocusPosition kMiddleBottomArrowFocusPositionDopendsOnDevice()
{
    ZZHintArrowFocusPosition focusPosition = ZZHintArrowFocusPositionMiddleRight;

    if (IS_IPAD)
    {
        focusPosition = ZZHintArrowFocusPositionTopRight;
    }

    return focusPosition;
}


@interface ZZHintsConstants : NSObject

@end

/**
* 3 step recognition secret gesture
*
* 1) Long press the logo    // TBMSecretGestureRecognizerStepLogoLongpressed
* 2) Move to menu button    // TBMSecretGestureRecognizerStepPanedToMenu
* 3) Move back to logo      // TBMSecretGestureRecognizerStepPanedToLogo
*
* Created by Maksim Bazarov on 26.05.15.
* Copyright (c) 2015 No Plan B. All rights reserved.
*
*/

typedef NS_ENUM(NSInteger, TBMSecretGestureRecognizerStep)
{
    TBMSecretGestureRecognizerStepDefault = 0,
    TBMSecretGestureRecognizerStepLogoLongpressed = 1,
    TBMSecretGestureRecognizerStepPanedToMenu = 2,
    TBMSecretGestureRecognizerStepPanedToLogo = 3,
};

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

static const float TBMSecretGestureLongPressTime = 0.5f;

@interface TBMSecretGestureRecognizer : UIGestureRecognizer
/**
 * View which should obtain recognition
 */
@property(nonatomic, weak) UIView *container;
/**
* Two views touches should move between
*/
@property(nonatomic, weak) UIView *menuView;
@property(nonatomic, weak) UIView *logoView;

@end
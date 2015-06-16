//
// Created by Maksim Bazarov on 13/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

//DKCrayonCrumble
NSString *const kTBMTutorialFontName;
typedef NS_ENUM(NSInteger, TBMHintArrowCurveKind) {
    TBMTutorialArrowCurveKindLeft = 0,
    TBMTutorialArrowCurveKindRight = 1,
};

@interface TBMHintArrow : UIView

@property(nonatomic, assign) TBMHintArrowCurveKind arrowCurveKind;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) CGFloat arrowAngle;
@property(nonatomic, assign) CGPoint arrowPoint;
@property(nonatomic, strong) UILabel *firstLabel;
@property(nonatomic, assign) BOOL hideArrow;

+ (TBMHintArrow *)arrowWithText:(NSString *)text
                      curveKind:(TBMHintArrowCurveKind)curveKind
                     arrowPoint:(CGPoint)point
                          angle:(CGFloat)angle
                         hidden:(BOOL)hidden
                          frame:(CGRect)frame;
@end
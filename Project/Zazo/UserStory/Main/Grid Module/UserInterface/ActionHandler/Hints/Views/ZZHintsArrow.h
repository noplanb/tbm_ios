//
// Created by Maksim Bazarov on 13/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kZZHintsFontName;
typedef NS_ENUM(NSInteger, ZZHintsArrowCurveKind)
{
    TBMTutorialArrowCurveKindLeft = 0,
    TBMTutorialArrowCurveKindRight = 1,
};

@interface ZZHintsArrow : UIView

@property(nonatomic, assign) ZZHintsArrowCurveKind arrowCurveKind;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) CGFloat arrowAngle;
@property(nonatomic, assign) CGPoint arrowPoint;
@property(nonatomic, strong) UILabel *arrowLabel;
@property(nonatomic, assign) BOOL hideArrow;

+ (ZZHintsArrow *)arrowWithText:(NSString *)text
                      curveKind:(ZZHintsArrowCurveKind)curveKind
                     arrowPoint:(CGPoint)point
                          angle:(CGFloat)angle
                         hidden:(BOOL)hidden
                          frame:(CGRect)frame
                 focusViewIndex:(NSInteger)index;
@end
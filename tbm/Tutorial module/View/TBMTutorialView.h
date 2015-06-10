//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBMTutorialArrowPoint) {
    TBMTutorialArrowPointFromTopToHorizCenter = 0,
    TBMTutorialArrowPointFromTopToHorizBottom = 1,
    TBMTutorialArrowPointFromTopToHorizTop = 2,
    TBMTutorialArrowPointFromTopToVertLeftCorner = 3,
};


NSString *const kTBMTutorialFontName;

@interface TBMTutorialView : UIView
@property(nonatomic, retain) UIColor *fillColor;
@property(nonatomic, retain) NSArray *framesToCutOut;

@property(nonatomic, strong) NSString *text;

@property(nonatomic) TBMTutorialArrowPoint arrowKind;
@end
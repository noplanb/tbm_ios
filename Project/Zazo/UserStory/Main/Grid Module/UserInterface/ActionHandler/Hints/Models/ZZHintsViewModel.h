//
//  ZZHintsViewModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
#import "ZZGridPart.h"

@class ZZHintsDomainModel;

typedef NS_ENUM(NSInteger, ZZHintPresentationState)
{
    ZZHintPresentationStateInactive,
    ZZHintPresentationStateActive,
    ZZHintPresentationStatePresented
};

@interface ZZHintsViewModel : NSObject

@property(nonatomic, assign)  ZZGridPart pointsToPart;

+ (instancetype)viewModelWithItem:(ZZHintsDomainModel*)item;

- (void)updateFocusFrame:(CGRect)focusFrame;

- (NSString*)text;
- (CGRect)focusFrame;

- (CGPoint)arrowFocusPointForIndex:(NSInteger)index;

- (CGFloat)arrowAngleForIndex:(NSInteger)index;

- (ZZArrowDirection)arrowDirectionForIndex:(NSInteger)index;
- (BOOL)hidesArrow;
- (ZZHintsBottomImageType)bottomImageType;


@end

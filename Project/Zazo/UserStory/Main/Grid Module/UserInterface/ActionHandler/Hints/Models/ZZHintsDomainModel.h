//
//  ZZHintsDomainModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
#import "ZZGridActionHandlerEnums.h"


typedef BOOL (^HintCondition)(ZZGridActionEventType event);

@interface ZZHintsDomainModel : NSObject

//Appearance
@property (nonatomic, assign) ZZHintsType type;
@property (nonatomic, assign) ZZArrowDirection arrowDirection;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) ZZHintsBottomImageType imageType;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* formatParameter;
@property (nonatomic, assign) BOOL hidesArrow;

//Logic
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) HintCondition condition;

//State
- (void)toggleStateTo:(BOOL)state;
@end

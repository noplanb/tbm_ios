//
//  ZZHintsDomainModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
#import "ZZGridActionHandlerEnums.h"
#import "ANBaseDomainModel.h"
#import "ZZGridPart.h"


typedef BOOL (^HintCondition)(ZZGridActionEventType event);

@interface ZZHintsDomainModel : ANBaseDomainModel

//Appearance
@property (nonatomic, assign) ZZHintsType type;
@property (nonatomic, assign) ZZHintsBottomImageType imageType;
@property (nonatomic, copy) NSString* formatParameter;
//arrow

@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL hidesArrow;
@property(nonatomic, assign)  ZZGridPart pointsTo;

//Logic
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) HintCondition condition;

//State
- (void)toggleStateTo:(BOOL)state;
@end

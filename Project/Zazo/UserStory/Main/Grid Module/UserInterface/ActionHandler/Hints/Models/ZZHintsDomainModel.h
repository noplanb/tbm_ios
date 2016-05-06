//
//  ZZHintsDomainModel.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@interface ZZHintsDomainModel : NSObject

@property (nonatomic, assign) ZZHintsType type;
@property (nonatomic, assign) ZZArrowDirection arrowDirection;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) ZZHintsBottomImageType imageType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *formatParameter;
@property (nonatomic, assign) BOOL hidesArrow;
@property (nonatomic, assign) NSInteger priority;

@end
//
//  ZZHintsController.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@interface ZZHintsController : NSObject

- (void)showHintWithType:(ZZHintsType)type focusFrame:(CGRect)frame withIndex:(NSInteger)index formatParameter:(NSString*)parameter;

@end

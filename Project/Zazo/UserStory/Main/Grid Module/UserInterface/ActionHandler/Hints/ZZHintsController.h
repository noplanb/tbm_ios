//
//  ZZHintsController.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@protocol ZZHintsControllerDelegate <NSObject>

- (void)hintWasDissmissed;

@end

@interface ZZHintsController : NSObject

@property (nonatomic, weak) id<ZZHintsControllerDelegate> delegate;

- (void)showHintWithType:(ZZHintsType)type focusFrame:(CGRect)frame withIndex:(NSInteger)index formatParameter:(NSString*)parameter;

@end

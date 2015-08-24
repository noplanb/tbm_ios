//
//  ZZLockControllerWithTouchDelay.h
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseTouchController.h"

@interface ZZTouchControllerWithTouchDelay : ZZBaseTouchController

- (instancetype)initWithDelay:(CGFloat)delay withStrategy:(id <ZZSecretScreenStrategy>)strategy withComplitionBlock:(void(^)())completionBlock;

@end

//
//  ZZLockControllerWithoutDelay.h
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseTouchController.h"

@interface ZZTouchControllerWithoutDelay : ZZBaseTouchController

- (instancetype)initWithStrategy:(id <ZZSecretScreenStrategy>)strategy withCompletionBlock:(void(^)())completionBlock;

@end

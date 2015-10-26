//
//  ZZSecretScreenController.h
//  Zazo
//
//  Created by ANODA on 10/26/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSecretScreenObserveTypes.h"


@interface ZZSecretScreenController : NSObject

+ (void)startObserveWithType:(ZZSecretScreenObserveType)observeType touchType:(ZZSecretScreenTouchType)touchType window:(UIWindow*)window completionBlock:(void(^)())completionBlock;

@end

//
//  ZZSecretScreenWireframe.h
//  Versoos
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenObserveTypes.h"
#import "ZZPushedSecretScreenTypes.h"


@interface ZZSecretScreenWireframe : NSObject

- (void)dismissSecretScreenController;
- (void)startSecretScreenObservingWithFirstTouchDelay:(CGFloat)delay
                                             withType:(ZZSecretScreenObserveType)type
                                           withWindow:(UIWindow*)window;
- (void)startSecretScreenObserveWithType:(ZZSecretScreenObserveType)type withWindow:(UIWindow*)window;

- (void)presentPushedSecretScreenControllerwithType:(ZZPushedScreenType)type;

@end

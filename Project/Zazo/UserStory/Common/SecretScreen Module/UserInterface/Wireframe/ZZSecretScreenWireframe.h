//
//  ZZSecretScreenWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenObserveTypes.h"

@interface ZZSecretScreenWireframe : NSObject

- (void)presentSecretScreenControllerFromNavigationController:(UINavigationController*)viewController;
- (void)dismissSecretScreenController;

- (void)startSecretScreenObservingWithFirstTouchDelay:(CGFloat)delay
                                             withType:(ZZSecretScreenObserveType)type
                                           withWindow:(UIWindow*)window;

- (void)startSecretScreenObserveWithType:(ZZSecretScreenObserveType)type withWindow:(UIWindow*)window;

- (void)presentLogsController;
- (void)presentStateController;

@end

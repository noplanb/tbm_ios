//
//  ZZRootWireframe.h
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZStartWireframe;
extern NSString *const ZZNeedsToShowSecretScreenNotificationName;

@interface ZZRootWireframe : NSObject

@property (nonatomic, strong) ZZStartWireframe *startWireframe;
- (void)showStartViewControllerInWindow:(UIWindow *)window completionBlock:(ANCodeBlock)completionBlock;

@end

//
//  ZZStartWireframe.h
//  Versoos
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZMainWireframe;

@interface ZZStartWireframe : NSObject

@property (nonatomic, strong) ZZMainWireframe *mainWireframe;

- (void)presentStartControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)dismissStartController;

#pragma mark - Details

- (void)presentMenuControllerWithGrid;
- (void)presentRegistrationController;
- (void)presentNetworkTestController;

@end
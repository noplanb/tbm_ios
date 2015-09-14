//
//  ZZEditFriendListWireframe.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZEditFriendListPresenter;

@interface ZZEditFriendListWireframe : NSObject

@property (nonatomic, strong) ZZEditFriendListPresenter* presenter;

- (void)presentEditFriendListControllerFromViewController:(UIViewController*)vc withCompletion:(ANCodeBlock)completion;
- (void)dismissEditFriendListController;

@end

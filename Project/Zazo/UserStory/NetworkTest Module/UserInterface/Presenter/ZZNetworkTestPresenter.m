//
//  ZZNetworkTestPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestPresenter.h"

@interface ZZNetworkTestPresenter ()

@end

@implementation ZZNetworkTestPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    ANDispatchBlockAfter(2.5, ^{
        [self startSending];
    });
}

- (void)startSending
{
    [self.interactor updateCredentials:^{
        [self.interactor startSendingVideo];
    }];
}

@end

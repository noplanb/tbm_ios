//
//  ZZNetworkTestVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestVC.h"
#import "ZZNetworkTestView.h"

@interface ZZNetworkTestVC ()

@property (nonatomic, strong) ZZNetworkTestView* networkTestView;

@end

@implementation ZZNetworkTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
}

- (void)loadView
{
    self.view = self.networkTestView;
}

#pragma mark - Private

- (ZZNetworkTestView *)networkTestView
{
    if (!_networkTestView)
    {
        _networkTestView = [ZZNetworkTestView new];
    }
    
    return _networkTestView;
}

@end

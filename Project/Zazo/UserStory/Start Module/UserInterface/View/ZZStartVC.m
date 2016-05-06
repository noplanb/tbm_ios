//
//  ZZStartVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartVC.h"
#import "ZZStartView.h"
#import "UIImage+ANDefault.h"

@interface ZZStartVC ()

@property (nonatomic, strong) ZZStartView *containerView;

@end

@implementation ZZStartVC

- (void)loadView
{
    self.view = self.containerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.containerView.backgroundImageView.image = [UIImage an_defaultImage];
}


#pragma mark - Private

- (ZZStartView *)containerView
{
    if (!_containerView)
    {
        _containerView = [ZZStartView new];
    }
    return _containerView;
}

@end

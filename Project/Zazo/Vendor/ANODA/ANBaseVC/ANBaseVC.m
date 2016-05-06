//
//  ANBaseVC.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseVC.h"

@implementation ANBaseVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)addRightNavigationButtonWithType:(ANBarButtonType)type block:(ANCodeBlock)block
{
    RACCommand *command = [RACCommand commandWithBlock:block];
    UIBarButtonItem *button = [UIBarButtonItem an_itemWithType:type command:command];
    [self.navigationItem an_addRightBarButtonItem:button];
}

- (void)addLeftNavigationButtonWithType:(ANBarButtonType)type block:(ANCodeBlock)block
{
    RACCommand *command = [RACCommand commandWithBlock:block];
    UIBarButtonItem *button = [UIBarButtonItem an_itemWithType:type command:command];
    [self.navigationItem an_addLeftBarButtonItem:button];
}

@end

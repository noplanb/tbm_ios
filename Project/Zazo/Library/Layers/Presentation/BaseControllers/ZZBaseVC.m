//
//  ZZBaseVC.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseVC.h"
#import "SVProgressHUD.h"

@interface ZZBaseVC ()

@end

@implementation ZZBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [ZZColorTheme shared].baseBackgroundColor;
}

- (void)updateStateToLoading:(BOOL)isLoading message:(NSString*)message
{
    if (ANIsEmpty(message))
    {
        message = @"Loading..."; // TODO: localizable
    }
    if (isLoading)
    {
        [SVProgressHUD showWithStatus:message];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

@end

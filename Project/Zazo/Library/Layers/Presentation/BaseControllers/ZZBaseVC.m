//
//  ZZBaseVC.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseVC.h"

@interface ZZBaseVC ()

@end

@implementation ZZBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [ZZColorTheme shared].baseBackgroundColor;
}

@end

//
//  ZZSecretVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretVC.h"
#import "ANTableContainerView.h"
#import "ZZSecretController.h"

@interface ZZSecretVC ()

@property (nonatomic, strong) ANTableContainerView* contentView;
@property (nonatomic, strong) ZZSecretController* controller;

@end

@implementation ZZSecretVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.contentView = [ANTableContainerView containerWithTableViewStyle:UITableViewStyleGrouped];
        self.controller = [[ZZSecretController alloc] initWithTableView:self.contentView.tableView];
    }
    return self;
}

- (void)loadView
{
    self.view = self.contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"secret-controller.header.title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

#pragma mark - User Interface

- (void)updateDataSource:(ZZSecretDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
}

@end

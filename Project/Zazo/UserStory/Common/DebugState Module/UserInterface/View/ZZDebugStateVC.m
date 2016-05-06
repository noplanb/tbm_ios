//
//  ZZDebugStateVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateVC.h"
#import "ZZDebugStateController.h"
#import "ANTableContainerView.h"
#import "ZZDebugStateDataSource.h"

@interface ZZDebugStateVC ()

@property (nonatomic, strong) ZZDebugStateController *controller;
@property (nonatomic, strong) ANTableContainerView *containerView;

@end

@implementation ZZDebugStateVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.containerView = [ANTableContainerView containerWithTableViewStyle:UITableViewStyleGrouped];
        self.controller = [[ZZDebugStateController alloc] initWithTableView:self.containerView.tableView];
    }
    return self;
}

- (void)loadView
{
    self.view = self.containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"debug-state.screen.title", nil);
}

- (void)updateDataSource:(ZZDebugStateDataSource *)dataSource
{
    self.controller.storage = dataSource.storage;
}

@end

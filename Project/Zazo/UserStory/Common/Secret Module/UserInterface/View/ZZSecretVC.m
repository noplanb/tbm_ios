//
//  ZZSecretVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretVC.h"
#import "ZZTableContainerView.h"
#import "ZZSecretController.h"
#import "ZZSecretDataSource.h"

@interface ZZSecretVC () <ZZSecretControllerDelegate>

@property (nonatomic, strong) ZZTableContainerView* contentView;
@property (nonatomic, strong) ZZSecretController* controller;

@end

@implementation ZZSecretVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.contentView = [ZZTableContainerView containerWithTableViewStyle:UITableViewStyleGrouped];
        self.controller = [[ZZSecretController alloc] initWithTableView:self.contentView.tableView];
        self.controller.delegate = self;
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
    
    self.title = NSLocalizedString(@"navTitle", nil);
    
    @weakify(self);
    [self addLeftNavigationButtonWithType:ANBarButtonTypeBack block:^{
        @strongify(self);
        [self.eventHandler backSelected];
    }];
}

#pragma mark - User Interface

- (void)updateDataSource:(ZZSecretDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
}

#pragma mark - CDTableController Delegate

- (void)itemSelectedWithModel:(ZZCellViewModel *)model
{
    
}

@end

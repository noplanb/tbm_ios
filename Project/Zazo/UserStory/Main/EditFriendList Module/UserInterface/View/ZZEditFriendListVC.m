//
//  ZZEditFriendListVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListVC.h"
#import "ZZEditFriendListController.h"
#import "ZZEditFriendListDataSource.h"
#import "ZZEditFriendView.h"
#import "ZZEditFriendCellViewModel.h"

@interface ZZEditFriendListVC () <ZZEditFriendListControllerDelegate>

@property (nonatomic, strong) ZZEditFriendView* contentView;
@property (nonatomic, strong) ZZEditFriendListController* controller;

@end

@implementation ZZEditFriendListVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.contentView = [ZZEditFriendView new];
        self.controller = [[ZZEditFriendListController alloc] initWithTableView:self.contentView.editFriendsTableView];
        self.controller.tableView.backgroundView = nil;
        self.controller.tableView.backgroundColor = [UIColor colorWithRed:0.85 green:0.84 blue:0.81 alpha:1];
        self.controller.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    self.title = NSLocalizedString(@"edit-friend.nav.title.text", nil);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - User Interface

- (void)updateDataSource:(ZZEditFriendListDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
}

#pragma mark - CDTableController Delegate

- (void)itemSelectedWithModel:(ZZEditFriendCellViewModel *)model
{
    
}

@end

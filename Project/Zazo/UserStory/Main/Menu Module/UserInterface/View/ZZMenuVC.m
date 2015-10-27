//
//  ZZMenuVC.m
//  zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuVC.h"
#import "ZZMenuController.h"
#import "ZZMenuView.h"

@interface ZZMenuVC () <ZZMenuControllerDelegate, ZZMenuControllerDelegate>

@property (nonatomic, strong) ZZMenuView* menuView;
@property (nonatomic, strong) ZZMenuController* controller;

@end

@implementation ZZMenuVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.menuView = [ZZMenuView new];
        self.controller = [[ZZMenuController alloc] initWithTableView:self.menuView.tableView];
        self.controller.searchBar = self.menuView.searchBar;
        self.controller.delegate = self;
    }
    return self;
}

- (void)loadView
{
    self.view = self.menuView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
}


#pragma mark - View Interface 

- (void)updateDataSource:(ZZMenuDataSource*)dataSource
{
    [self.controller updateDataSource:dataSource];
}

- (void)reset
{
    [self.controller reset];
}

- (void)needToUpdateDataSource
{
    [self.controller updateDataSource:[self.eventHandler dataSource]];
}

#pragma mark - Controller Delegate

- (void)itemSelected:(ZZMenuCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        [self.controller.searchBar resignFirstResponder];
        [self.view endEditing:YES];
    });
    [self.eventHandler itemSelected:model];
}

@end

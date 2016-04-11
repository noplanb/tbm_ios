//
//  ZZContactsVC.m
//  zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsVC.h"
#import "ZZContactsController.h"
#import "ZZContactsView.h"

@interface ZZContactsVC () <ZZMenuControllerDelegate, ZZMenuControllerDelegate>

@property (nonatomic, strong) ZZContactsView * menuView;
@property (nonatomic, strong) ZZContactsController * controller;

@end

@implementation ZZContactsVC

@dynamic tabbarViewItemImage;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.menuView = [ZZContactsView new];
        self.controller = [[ZZContactsController alloc] initWithTableView:self.menuView.tableView];
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
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.eventHandler menuToggled];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [self.controller searchBarCancelButtonClicked:self.controller.searchBar];
    self.controller.searchBar.text = nil;
}

#pragma mark - View Interface 

- (void)updateDataSource:(ZZContactsDataSource *)dataSource
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

- (void)reloadContactView
{
    [self.controller reloadContactData];
}

- (UIImage *)tabbarViewItemImage
{
    return [UIImage imageNamed:@"profile"];
}

#pragma mark - Controller Delegate

- (void)itemSelected:(ZZContactCellViewModel *)model
{
    ANDispatchBlockToMainQueue(^{
        [self.controller.searchBar resignFirstResponder];
        [self.view endEditing:YES];
    });
    [self.eventHandler itemSelected:model];
}

@end

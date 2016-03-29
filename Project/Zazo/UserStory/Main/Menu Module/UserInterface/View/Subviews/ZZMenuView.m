//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuView.h"
#import "ZZMenuHeaderView.h"


@implementation ZZMenuView

@synthesize headerView = _headerView, tableView = _tableView;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self makeLayout];
    }

    return self;
}

- (void)makeLayout
{
    [self addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (ZZMenuHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[ZZMenuHeaderView alloc] init];
    }
    return _headerView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}


@end
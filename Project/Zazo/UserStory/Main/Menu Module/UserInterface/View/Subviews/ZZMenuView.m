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
        make.left.right.bottom.equalTo(self);
    }];

    [self addSubview:self.headerView];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.tableView.mas_top);
    }];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(8,0,0,0);
        _tableView.scrollsToTop = NO;
    }
    return _tableView;
}


- (ZZMenuHeaderView *)headerView
{
    if (!_headerView)
    {
        _headerView = [[ZZMenuHeaderView alloc] init];
    }
    return _headerView;
}

@end
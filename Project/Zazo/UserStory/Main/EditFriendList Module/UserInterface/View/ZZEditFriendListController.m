//
//  ZZEditFriendListController.m
//  Zazo
//
//  Created by ANODA on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListController.h"
#import "ANBaseTableHeaderView.h"
#import "ZZEditFriendListDataSource.h"
#import "ZZEditFriendCell.h"
#import "ZZEditFriendCellViewModel.h"

@implementation ZZEditFriendListController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZEditFriendCell class] forModelClass:[ZZEditFriendCellViewModel class]];
        self.displayHeaderOnEmptySection = NO;
        self.tableView.rowHeight = 60;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate itemSelectedWithModel:[self.storage objectAtIndexPath:indexPath]];
}

- (void)updateDataSource:(ZZEditFriendListDataSource *)dataSource
{
    self.storage = dataSource.storage;
}

@end

//
//  ZZSecretController.m
//  Zazo
//
//  Created by ANODA on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretController.h"
#import "ANBaseTableHeaderView.h"
#import "ZZSecretDataSource.h"

@interface ZZSecretController ()

@property (nonatomic, weak) ZZSecretDataSource *dataSource;

@end

@implementation ZZSecretController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZSecretSwitchCell class] forModelClass:[ZZSecretSwitchCellViewModel class]];
        [self registerCellClass:[ZZSecretSegmentCell class] forModelClass:[ZZSecretSegmentCellViewModel class]];
        [self registerCellClass:[ZZSecretValueCell class] forModelClass:[ZZSecretValueCellViewModel class]];
        [self registerCellClass:[ZZSecretScreenTextEditCell class] forModelClass:[ZZSecretScreenTextEditCellViewModel class]];

        [self registerHeaderClass:[ANBaseTableHeaderView class] forModelClass:[NSString class]];

        self.tableView.sectionHeaderHeight = 46;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.rowHeight = 44;
        self.displayHeaderOnEmptySection = NO;
    }
    return self;
}

- (void)updateDataSource:(ZZSecretDataSource *)dataSource
{
    self.dataSource = dataSource;
    self.storage = dataSource.storage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource itemSelectedAtIndexPath:indexPath];
}

@end

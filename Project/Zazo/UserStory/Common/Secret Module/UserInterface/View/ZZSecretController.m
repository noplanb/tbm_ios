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
#import "ZZSecretButtonCell.h"
#import "ZZSecretSwitchCell.h"
#import "ZZSecretSwitchServerCell.h"
#import "ZZSecretSegmentControlCell.h"

@implementation ZZSecretController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZSecretButtonCell class] forModelClass:[ZZSecretButtonCellViewModel class]];
        [self registerCellClass:[ZZSecretSwitchCell class] forModelClass:[ZZSecretSwitchCellViewModel class]];
        [self registerCellClass:[ZZSecretSwitchServerCell class] forModelClass:[ZZSecretSwitchServerCellViewModel class]];
        [self registerCellClass:[ZZSecretSegmentControlCell class] forModelClass:[ZZSecretSegmentControlCellViewModel class]];
        [self registerHeaderClass:[ANBaseTableHeaderView class] forModelClass:[NSString class]];
        self.tableView.sectionHeaderHeight = 30;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.displayHeaderOnEmptySection = NO;
    }
    return self;
}

- (void)updateDataSource:(ZZSecretDataSource *)dataSource
{
    self.storage = dataSource.storage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate itemSelectedWithModel:[self.storage objectAtIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.storage objectAtIndexPath:indexPath];
    
    if ([model isMemberOfClass:[ZZSecretSwitchServerCellViewModel class]])
    {
        return 100;
    }
    else
    {
        return 44;
    }
}

@end

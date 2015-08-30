//
//  ZZSecretController.m
//  Zazo
//
//  Created by Oleg Panforov on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretController.h"
#import "ANBaseTableHeaderView.h"
#import "ZZSecretDataSource.h"

@implementation ZZSecretController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZCell class] forModelClass:[ZZCellViewModel class]];
        [self registerHeaderClass:[ANBaseTableHeaderView class] forModelClass:[NSString class]];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate itemSelectedWithModel:[self.storage objectAtIndexPath:indexPath]];
}

- (void)updateDataSource:(ZZSecretDataSource *)dataSource
{
    self.storage = dataSource.storage;
}

@end

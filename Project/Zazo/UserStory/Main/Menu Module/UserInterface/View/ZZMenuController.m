//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuController.h"
#import "ZZMenuCell.h"
#import "ZZMenuCellModel.h"
#import "ANBaseTableHeaderView.h"

@implementation ZZMenuController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];

    if (!self)
    {
        return nil;
    }

    [self registerCellClass:[ZZMenuCell class] forModelClass:[ZZMenuCellModel class]];
    [self registerHeaderClass:[ANBaseTableHeaderView class] forModelClass:[NSString class]];
    
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.delegate controller:self didSelectModel:
            [self.storage objectAtIndexPath:indexPath]];
}

@end

//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuController.h"
#import "ZZMenuCell.h"
#import "ZZMenuCellModel.h"


@implementation ZZMenuController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    
    if (!self)
    {
        return nil;
    }
    
    [self registerCellClass:[ZZMenuCell class] forModelClass:[ZZMenuCellModel class]];
    
    return self;
}

@end
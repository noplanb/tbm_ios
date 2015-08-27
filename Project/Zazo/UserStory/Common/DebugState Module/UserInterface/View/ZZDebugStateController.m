//
//  ZZDebugStateController.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateController.h"
#import "ZZDebugStateDataSource.h"

@implementation ZZDebugStateController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZDebugStateCell class] forModelClass:[ZZDebugStateCellViewModel class]];
    }
    return self;
}

@end

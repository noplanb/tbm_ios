//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZMenuHeaderView;


@interface ZZMenuView : UIView

@property (nonatomic, strong, readonly) ZZMenuHeaderView *headerView;
@property (nonatomic, strong, readonly) UITableView *tableView;

@end
//
//  ZZEditFriendListController.h
//  Zazo
//
//  Created by ANODA on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANTableController.h"

@class ZZEditFriendListDataSource;
@class ZZEditFriendCellViewModel;

@protocol ZZEditFriendListControllerDelegate <NSObject>

- (void)itemSelectedWithModel:(ZZEditFriendCellViewModel *)model;

@end

@interface ZZEditFriendListController : ANTableController

@property (nonatomic, weak) id<ZZEditFriendListControllerDelegate> delegate;

- (void)updateDataSource:(ZZEditFriendListDataSource*)dataSource;

@end

//
//  ZZEditFriendListViewInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZEditFriendListDataSource;

@protocol ZZEditFriendListViewInterface <NSObject>

- (void)updateDataSource:(ZZEditFriendListDataSource*)dataSource;

@end

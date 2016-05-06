//
//  ZZContactsViewInterface.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZContactsDataSource;

@protocol ZZContactsViewInterface <NSObject>

- (void)updateDataSource:(ZZContactsDataSource *)dataSource;

- (void)reset;

- (void)reloadContactView;

@end

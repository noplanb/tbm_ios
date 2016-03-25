//
//  ZZContactsModuleInterface.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZContactsDataSource;

@protocol ZZContactsModuleInterface <NSObject>

- (void)itemSelected:(id)item;
- (void)menuToggled;
- (ZZContactsDataSource *)dataSource;

@end

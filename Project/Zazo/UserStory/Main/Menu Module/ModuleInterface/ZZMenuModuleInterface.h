//
//  ZZMenuModuleInterface.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZMenuDataSource;

@protocol ZZMenuModuleInterface <NSObject>

- (void)itemSelected:(id)item;
- (void)menuToggled;
- (ZZMenuDataSource*)dataSource;

@end

//
//  ZZMenuViewInterface.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZMenuDataSource;

@protocol ZZMenuViewInterface <NSObject>

- (void)updateDataSource:(ZZMenuDataSource*)dataSource;

@end

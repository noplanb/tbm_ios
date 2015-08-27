//
//  ZZDebugStateViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZDebugStateDataSource;

@protocol ZZDebugStateViewInterface <NSObject>

- (void)updateDataSource:(ZZDebugStateDataSource*)dataSource;

@end

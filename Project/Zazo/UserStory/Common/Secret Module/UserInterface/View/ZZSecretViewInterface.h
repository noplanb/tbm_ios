//
//  ZZSecretViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZSecretDataSource;

@protocol ZZSecretViewInterface <NSObject>

- (void)updateDataSource:(ZZSecretDataSource*)dataSource;

@end

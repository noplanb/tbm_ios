//
//  ZZSecretController.h
//  Zazo
//
//  Created by ANODA on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANTableController.h"

@class ZZSecretDataSource;

@interface ZZSecretController : ANTableController

- (void)updateDataSource:(ZZSecretDataSource*)dataSource;

@end

//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage;
@class ZZGridDomainModel;
@class ZZGridCellViewModel;

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)reloadModel:(ZZGridCellViewModel*)model;

@end

//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage, ZZGridDomainModel, ZZGridCollectionCellViewModel;

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)updateModel:(ZZGridCollectionCellViewModel *)model;

@end

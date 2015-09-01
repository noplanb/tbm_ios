//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANMemoryStorage, ZZGridDomainModel ;

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)updateModel:(ZZGridDomainModel *)model;

@end

//
//  ZZGridActionDataProvider.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionDataProvider.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDomainModel.h"

@implementation ZZGridActionDataProvider

+ (NSInteger)numberOfUsersOnGrid
{
    NSArray *gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    
    __block NSInteger counter = 0;
    [gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!ANIsEmpty(model.relatedUser))
        {
            counter++;
        }
    }];
     
    return counter;
}

@end

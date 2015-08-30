//
//  ZZSecretDataSource.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretDataSource.h"
#import "ANMemoryStorage.h"

@implementation ZZSecretDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
    }
    return self;
}

- (void)setupStorageWithModels:(NSArray *)list
{
    [list enumerateObjectsUsingBlock:^(ZZCellViewModel *model, NSUInteger idx, BOOL *stop) {
        model.delegate = self;
    }];

    [self.storage batchUpdateWithBlock:^{
        [self _addSectionWithItems:list];
    }];
}

#pragma mark - Private

- (void)_addSectionWithItems:(NSArray*)items
{
    if (!ANIsEmpty(items))
    {
        [self.storage addItems:items toSection:ZZSectionOne];
    }
    [self.storage setSectionHeaderModel:NSLocalizedString(@"SectionOneTitle", nil) forSectionIndex:ZZSectionOne];
}


@end

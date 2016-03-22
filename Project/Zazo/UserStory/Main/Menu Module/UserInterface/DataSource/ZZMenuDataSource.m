//
//  ZZMenuDataSource.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuDataSource.h"
#import "ANMemoryStorage.h"
#import "ANMemoryStorage+UpdateWithoutAnimations.h"
#import "NSArray+ZZAdditions.h"

@implementation ZZMenuDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
    }
    return self;
}

- (void)setupFriendsThatHaveAppItems:(NSArray*)items
{
    [self _addItems:items toSection:ZZMenuSectionsFriendsHasApp];
}

- (void)setupFriendsItems:(NSArray*)items
{
    [self _addItems:items toSection:ZZMenuSectionsFriends];
}

- (void)setupAddressbookItems:(NSArray*)items
{
    
    NSDictionary *groupedItems = [items zz_groupByKeyPath:@"category"];
    NSArray *keys = [groupedItems allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    ANDispatchBlockToMainQueue(^{        
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.storage setSectionHeaderModel:obj
                                forSectionIndex:idx];
            
            [self _addItems:groupedItems[obj] toSection:idx];
            
        }];
    });
    
}


#pragma mark - Private

- (void)_addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex
{
    items = [[items.rac_sequence map:^id(id value) {
        return [ZZMenuCellViewModel viewModelWithItem:value];
    }] array];
    
    ANDispatchBlockToMainQueue(^{
        ANSectionModel* section = [self.storage sectionAtIndex:sectionIndex createIfNeeded:YES];
        [section.objects removeAllObjects];
        section = [self.storage sectionAtIndex:sectionIndex createIfNeeded:YES];
        [section.objects addObjectsFromArray:items];
        [self.storage.delegate storageNeedsReload];
    });
}

@end

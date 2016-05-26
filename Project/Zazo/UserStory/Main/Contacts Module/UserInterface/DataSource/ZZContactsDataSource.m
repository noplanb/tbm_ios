//
//  ZZContactsDataSource.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsDataSource.h"
#import "ANMemoryStorage.h"
#import "ANMemoryStorage+UpdateWithoutAnimations.h"
#import "NSArray+ZZAdditions.h"

@interface ZZContactsDataSource () <ANStorageDelegate>

@property (nonatomic, strong) NSArray *allItems;

@end

@implementation ZZContactsDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
        self.storage.delegate = self;

    }
    return self;
}

- (void)setupFriendsThatHaveAppItems:(NSArray *)items
{
    [self.storage setSectionHeaderModel:@"★"
                        forSectionIndex:ZZMenuSectionsFriendsHasApp];

    [self _addItems:items toSection:ZZMenuSectionsFriendsHasApp];
}

- (void)setupAllFriendItems:(NSArray *)items
{
    NSArray *cellModels = [items.rac_sequence map:^id(id value) {
        ZZContactCellViewModel *cellModel = [ZZContactCellViewModel new];
        cellModel.item = value;
        return cellModel;
    }].array;

    self.allItems = cellModels;
}

- (void)setupAddressbookItems:(NSArray *)items
{
    NSDictionary *groupedItems = [items zz_groupByKeyPath:@"category"];
    NSArray *keys = [groupedItems allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    ANDispatchBlockToMainQueue(^{
        [keys enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [self.storage setSectionHeaderModel:obj
                                forSectionIndex:idx + 1];

            [self _addItems:groupedItems[obj] toSection:idx + 1];

        }];
    });

}

#pragma mark ANStorageDelegate

- (ANMemoryStorage *)storage:(ANMemoryStorage *)aStorage
      storageForSearchString:(NSString *)searchString
               inSearchScope:(NSUInteger)searchScope
{
    ANMemoryStorage *storage = [ANMemoryStorage new];
    storage.supplementaryHeaderKind = aStorage.supplementaryHeaderKind;
    [storage setSectionHeaderModel:@"★" forSectionIndex:ZZMenuSectionsFriendsHasApp];
    
    NSPredicate *predicate;
    
    if (aStorage.storagePredicateBlock)
    {
        predicate = aStorage.storagePredicateBlock(searchString, searchScope);
    }
    
    if (predicate)
    {
        [aStorage.sections enumerateObjectsUsingBlock:^(ANSectionModel *obj, NSUInteger idx, BOOL *stop) {
            
            if (idx == ZZMenuSectionsFriendsHasApp)
            {
                return;
            }
            
            NSArray *filteredObjects = [obj.objects filteredArrayUsingPredicate:predicate];
            
            if (filteredObjects.count > 0)
            {
                [storage setSectionHeaderModel:[obj supplementaryModelOfKind:storage.supplementaryHeaderKind]
                               forSectionIndex:idx];
                
                [storage addItems:filteredObjects toSection:idx];
            }
        }];
        
        if (!ANIsEmpty(self.allItems))
        {
            NSArray *filteredCellModelss = [self.allItems filteredArrayUsingPredicate:predicate];
            
            if (!ANIsEmpty(filteredCellModelss))
            {
                [storage addItems:filteredCellModelss toSection:ZZMenuSectionsFriendsHasApp];
            }
        }
    }
    else
    {
        NSLog(@"No predicate was created, so no searching. Check your setter for storagePredicateBlock");
    }
    
    return storage;
    
}


#pragma mark - Private

- (void)_addItems:(NSArray *)items toSection:(NSUInteger)sectionIndex
{
    items = [[items.rac_sequence map:^id(id value) {
        return [ZZContactCellViewModel viewModelWithItem:value];
    }] array];

    ANDispatchBlockToMainQueue(^{
        ANSectionModel *section = [self.storage sectionAtIndex:sectionIndex createIfNeeded:YES];
        [section.objects removeAllObjects];
        section = [self.storage sectionAtIndex:sectionIndex createIfNeeded:YES];
        [section.objects addObjectsFromArray:items];
        [self.storage.updatingInterface storageNeedsReload];
    });
}

@end

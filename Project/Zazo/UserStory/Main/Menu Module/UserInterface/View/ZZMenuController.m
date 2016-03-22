//
//  ZZMenuController.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuController.h"
#import "ZZMenuDataSource.h"
#import "ZZMenuTableHeaderView.h"

@implementation ZZMenuController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        self.tableView.rowHeight = 55.5;
        self.tableView.sectionHeaderHeight = 1;
        [self registerCellClass:[ZZMenuCell class] forModelClass:[ZZMenuCellViewModel class]];
        [self registerHeaderClass:[ZZMenuTableHeaderView class] forModelClass:[NSString class]];
        self.displayHeaderOnEmptySection = NO;
    }
    return self;
}

- (void)updateDataSource:(ZZMenuDataSource*)dataSource
{
    self.storage = dataSource.storage;
    self.searchingStorage = dataSource.storage;
    
    self.memoryStorage.storagePredicateBlock = ^NSPredicate *(NSString* searchString, NSInteger scope){
        
        NSPredicate* firstNamePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",@"item.firstName", searchString];
        NSPredicate* lastNamePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",@"item.lastName", searchString];
        return [NSCompoundPredicate orPredicateWithSubpredicates:@[firstNamePredicate,lastNamePredicate]];
    };
}

- (void)reset
{
    ANDispatchBlockToMainQueue(^{
        self.searchBar.text = @"";
        [self filterTableItemsForSearchString:self.searchBar.text];
        [self.delegate needToUpdateDataSource];
        [self.tableView setContentOffset:CGPointZero];
    });
}


#pragma mark - Update storage

- (void)storageDidPerformUpdate:(ANStorageUpdate *)update
{
    [self _reloadContactData];
}

- (void)reloadContactData
{
    [self _reloadContactData];
}

- (void)_reloadContactData
{
    ANDispatchBlockToMainQueue(^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZZMenuCellViewModel* model = [self.currentStorage objectAtIndexPath:indexPath];
    [self.delegate itemSelected:model];
}

- (void)_performAnimatedUpdate:(ANStorageUpdate*)update
{
    ANDispatchBlockToMainQueue(^{
        [self.tableView reloadData];
    });
}

@end

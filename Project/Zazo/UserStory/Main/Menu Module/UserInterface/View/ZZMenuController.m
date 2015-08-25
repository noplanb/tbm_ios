//
//  ZZMenuController.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuController.h"
#import "ZZMenuDataSource.h"

static CGFloat const kTableViewRowHeight = 68;

@implementation ZZMenuController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        tableView.rowHeight = kTableViewRowHeight;
        [self registerCellClass:[ZZMenuCell class] forModelClass:[ZZMenuCellViewModel class]];
    }
    return self;
}

- (void)updateDataSource:(ZZMenuDataSource*)dataSource
{
    self.storage = dataSource.storage;
    self.searchingStorage = dataSource.storage;
    self.memoryStorage.storagePredicateBlock = ^NSPredicate *(NSString* searchString, NSInteger scope){
        NSPredicate* firstNamePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",@"item.firstName",searchString];
        NSPredicate* lastNamePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",@"item.lastName",searchString];
        return [NSCompoundPredicate orPredicateWithSubpredicates:@[firstNamePredicate,lastNamePredicate]];
    };
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZZMenuCellViewModel* model = [self.storage objectAtIndexPath:indexPath];
    [self.delegate itemSelected:model];
}

@end

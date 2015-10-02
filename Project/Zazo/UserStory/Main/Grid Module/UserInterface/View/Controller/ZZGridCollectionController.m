//
//  ZZGridCollectionController.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionController.h"
#import "ZZGridDataSource.h"

@interface ZZGridCollectionController () <ZZGridDataSourceControllerDelegate>

@property (nonatomic, strong) ZZGridDataSource* dataSource;

@end

@implementation ZZGridCollectionController

- (void)reload
{
    NSArray* items = [self.delegate items];
    [items enumerateObjectsUsingBlock:^(id <ANModelTransfer> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id model = [self.dataSource modelAtIndex:idx];
        [obj updateWithModel:model];
    }];
}

- (void)reloadItem:(id)item
{
    NSInteger index = [self.dataSource indexForModel:item];
    if (index != NSNotFound)
    {
        [self reloadItemAtIndex:index];
    }
}

- (void)reloadItemAtIndex:(NSInteger)index
{
    id<ANModelTransfer> item = nil;
    if ([self.delegate items].count > index)
    {
        item = (id<ANModelTransfer>)[self.delegate items][index];
    }
    id model = [self.dataSource modelAtIndex:index];
    if (item)
    {
        [item updateWithModel:model];
    }
}

- (void)updateDataSource:(ZZGridDataSource*)dataSource
{
    self.dataSource = dataSource;
    self.dataSource.controllerDelegate = self;
}

- (void)showContainFriendAnimaionWithFriend:(ZZFriendDomainModel*)friendModel
{
//    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
//        
//        if ([cell isKindOfClass:[ZZGridCell class]])
//        {
//            ZZGridCell* gridCell = (ZZGridCell *)cell;
//            ZZGridCellViewModel* cellModel = [gridCell model];
//            if ([cellModel.item.relatedUser isEqual:friendModel])
//            {
//                [gridCell showContainFriendAnimation];
//            }
//        }
//    }];
}

@end

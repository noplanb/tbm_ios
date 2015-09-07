//
//  ZZGridCollectionController.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionController.h"
#import "ZZGridCell.h"
#import "ZZGridCenterCell.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCenterCellViewModel.h"
#import "ANRuntimeHelper.h"
#import "ANMemoryStorage.h"
#import "ZZGridCellViewModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridDataSource.h"

static NSInteger const kCenterCellIndex = 4;

@interface ZZGridCollectionController ()

@property (nonatomic, strong) ZZGridCenterCell* centerCell;
@property (nonatomic, strong) ZZGridDataSource* dataSource;

@end

@implementation ZZGridCollectionController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    if (self = [super initWithCollectionView:collectionView])
    {
        [self registerCellClass:[ZZGridCell class] forModelClass:[ZZGridCellViewModel class]];
        [self registerCellClass:[ZZGridCenterCell class] forModelClass:[ZZGridCenterCellViewModel class]];
    }
    
    return self;
}

- (void)updateDataSource:(ZZGridDataSource*)dataSource
{
    self.dataSource = dataSource;
    self.storage = dataSource.storage;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCellContainUserModel:collectionView withIndexPath:indexPath] && indexPath.item != kCenterCellIndex)
    {
        [self.dataSource itemSelectedAtIndexPath:indexPath];
    }
}

- (BOOL)isCellContainUserModel:(UICollectionView*)collectionView withIndexPath:(NSIndexPath *)indexPath
{
    BOOL isHasUser = NO;
    
    id cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ZZGridCell class]])
    {
        ZZGridCell* gridCell = (ZZGridCell*)cell;
        ZZGridCellViewModel* model = [gridCell model];
        isHasUser = (model.item.relatedUser != nil);
    }
    
    return isHasUser;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell;
    
    if (indexPath.item == kCenterCellIndex)
    {
        if (!self.centerCell)
        {
            self.centerCell = (ZZGridCenterCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
        }
        cell = self.centerCell;
    }
    else
    {
        cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)showContainFriendAnimaionWithFriend:(ZZFriendDomainModel*)friendModel
{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
       
        if ([cell isKindOfClass:[ZZGridCell class]])
        {
            ZZGridCell* gridCell = (ZZGridCell *)cell;
            ZZGridCellViewModel* cellModel = [gridCell model];
            if ([cellModel.item.relatedUser isEqual:friendModel])
            {
                [gridCell showContainFriendAnimation];
            }
        }
    }];

}

@end

//
//  ZZGridCollectionController.m
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionController.h"
#import "ZZGridCollectionCell.h"
#import "ZZGridCenterCell.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCenterCellViewModel.h"

@interface ZZGridCollectionController ()

@end

@implementation ZZGridCollectionController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    if (self = [super initWithCollectionView:collectionView])
    {
        [self registerCellClass:[ZZGridCollectionCell class] forModelClass:[ZZGridDomainModel class]];
        [self registerCellClass:[ZZGridCenterCell class] forModelClass:[ZZGridCenterCellViewModel class]];
    }
    
    return self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCellContainUserModel:collectionView withIndexPath:indexPath])
    {
        [self.delegate selectedViewWithIndexPath:indexPath];
    }
}

- (BOOL)isCellContainUserModel:(UICollectionView* )collectionView withIndexPath:(NSIndexPath *)indexPath
{
    BOOL isHasUser = NO;
    
    id cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ZZGridCollectionCell class]])
    {
        ZZGridCollectionCell* gridCell = (ZZGridCollectionCell*)cell;
        ZZGridDomainModel* model = [gridCell model];
        isHasUser = (model.relatedUser != nil);
    }
    
    return isHasUser;
}


@end

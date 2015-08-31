//
//  ZZGridCollectionController.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionController.h"
#import "ZZGridCollectionCell.h"
#import "ZZGridCenterCell.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCenterCellViewModel.h"
#import "ANRuntimeHelper.h"
#import "ANMemoryStorage.h"

static NSInteger const kCenterCellIndex = 4;

@interface ZZGridCollectionController ()

@property (nonatomic, strong) ZZGridCenterCell* centerCell;

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
        ZZGridCollectionCell* cell = (ZZGridCollectionCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        ZZGridDomainModel* model = [cell model];
        [self.delegate selectedViewWithModel:model];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell;
 
    if (indexPath.item == kCenterCellIndex)
    {
        if (!self.centerCell)
        {
            NSString * classString = [ANRuntimeHelper classStringForClass:[ZZGridCenterCell class]];
            self.centerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:classString forIndexPath:indexPath];
            [self.centerCell updateWithModel:[(ANMemoryStorage*)self.storage itemAtIndexPath:indexPath]];
        }
        cell = self.centerCell;
    }
    else
    {
        NSString * classString = [ANRuntimeHelper classStringForClass:[ZZGridCollectionCell class]];
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:classString forIndexPath:indexPath];
        ZZGridBaseCell* baseCell = (ZZGridBaseCell*)cell;
        
        ZZGridDomainModel* dmodel = [(ANMemoryStorage*)self.storage itemAtIndexPath:indexPath];
        ANSectionModel* ss = [((ANMemoryStorage*)self.storage).sections firstObject];
        [baseCell updateWithModel:[(ANMemoryStorage*)self.storage itemAtIndexPath:indexPath]];
    }
    
    return cell;
}


@end

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
        id model = [self.dataSource viewModelAtIndex:idx];
        [obj updateWithModel:model];
    }];
}

- (void)reloadItem:(id)item
{
    NSInteger index = [self.dataSource indexForViewModel:item];
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
    id model = [self.dataSource viewModelAtIndex:index];
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


#pragma mark - Index view on grid after rotate

- (void)updateInitialViewFramesIfNeeded
{
    [self _setupFramesIfNeeded];
}

- (void)_setupFramesIfNeeded
{
    
    if (ANIsEmpty(self.initalFrames))
    {
        self.initalFrames = [NSMutableArray new];
        [[self.delegate items] enumerateObjectsUsingBlock:^(UIView*  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.initalFrames addObject:[NSValue valueWithCGRect:view.frame]];
        }];
    }
}

- (NSInteger)indexOfFriendModelOnGrid:(ZZFriendDomainModel*)friendModel;
{
    __block NSInteger index = NSNotFound;
    ZZGridCell* gridCell = [self gridCellWithFriendModel:friendModel];
    
    if (!ANIsEmpty(gridCell))
    {
        [self.initalFrames enumerateObjectsUsingBlock:^(NSValue*  _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = [value CGRectValue];
            if (CGRectContainsPoint(frame, gridCell.center))
            {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

- (ZZGridCell*)gridCellWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    __block ZZGridCell* gridCell = nil;
    
    [[self.delegate items] enumerateObjectsUsingBlock:^(id <ANModelTransfer> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id model = [obj model];
        if ([model isKindOfClass:[ZZGridCellViewModel class]])
        {
            ZZGridCellViewModel* viewModel = model;
            if ([viewModel.item.relatedUser isEqual:friendModel])
            {
                gridCell =(ZZGridCell*)obj;
                *stop = YES;
            }
        }
    }];
    
    return gridCell;
}

@end

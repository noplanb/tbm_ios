//
//  ZZGridVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridVC.h"
#import "ZZGridView.h"
#import "ZZGridCollectionController.h"
#import "ZZGridDataSource.h"
#import "ZZGridRotationTouchObserver.h"
#import "ZZGridUIConstants.h"
#import "ZZTabbarView.h"

@interface ZZGridVC () <ZZGridRotationTouchObserverDelegate, ZZGridCollectionControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZZGridView *gridView;
@property (nonatomic, strong) ZZGridCollectionController *controller;
@property (nonatomic, strong) ZZGridRotationTouchObserver *touchObserver;

@end

@implementation ZZGridVC

@dynamic tabbarViewItemImage;

- (instancetype)init
{
    if (self = [super init])
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.size.height -= ZZTabbarViewHeight + 12;

        self.gridView = [[ZZGridView alloc] initWithFrame:frame];

        self.controller = [ZZGridCollectionController new];
        self.controller.delegate = self;

        self.touchObserver = [[ZZGridRotationTouchObserver alloc] initWithGridView:self.gridView];
        self.touchObserver.delegate = self;

        self.gridView.itemsContainerView.touchObserver = self.touchObserver;

        [[RACObserve(self.touchObserver, isMoving) filter:^BOOL(NSNumber *value) {
            return [value boolValue];
        }] subscribeNext:^(id x) {
            [self.eventHandler hideHintIfNeeded];
        }];
    }
    return self;
}

- (NSArray *)items
{
    return self.gridView.items;
}

- (void)loadView
{
    self.view = self.gridView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.controller updateInitialViewFramesIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.eventHandler stopPlaying];
}

- (void)tabbarItemDidDisappear
{
    [self.eventHandler stopPlaying];
}

- (void)updateWithDataSource:(ZZGridDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
}

- (void)updateLoadingStateTo:(BOOL)isLoading
{
    [self updateStateToLoading:isLoading message:nil];
}

#pragma mark VC Interface

- (void)prepareForCameraSwitchAnimation
{
    NSInteger centerCellIndex = 4;
    [self.gridView.items[centerCellIndex] prepareForCameraSwitchAnimation];

}

- (void)showCameraSwitchAnimation
{
    NSInteger centerCellIndex = 4;
    [self.gridView.items[centerCellIndex] showCameraSwitchAnimation];
}

- (void)showFriendAnimationWithFriendModel:(ZZFriendDomainModel *)friendModel
{
    ZZGridCell *animationCell = [self.controller gridCellWithFriendModel:friendModel];
    [animationCell showContainFriendAnimation];
}

- (void)updateDownloadingProgressTo:(CGFloat)progress forModel:(ZZFriendDomainModel *)friendModel
{
    ZZGridCell *cell = [self cellForFriendModel:friendModel];

    [cell setDownloadProgress:progress];
}

- (ZZGridCell *)cellForFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSArray *items = self.gridView.itemsContainerView.items;

    __block ZZGridCell *result = nil;

    [items enumerateObjectsUsingBlock:^(ZZGridCell *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![obj isKindOfClass:[ZZGridCell class]])
        {
            return;
        }

        ZZGridCellViewModel *model = obj.model;

        if (![model isKindOfClass:[ZZGridCellViewModel class]])
        {
            return;
        }

        if (![model.item.relatedUser isEqual:friendModel])
        {
            return;
        }

        result = obj;
        *stop = YES;
    }];

    return result;
}

- (BOOL)isGridRotating
{
    return [self.touchObserver isGridRotate];
}

- (NSInteger)indexOfFriendModelOnGridView:(ZZFriendDomainModel *)frindModel
{
    return [self.controller indexOfFriendModelOnGrid:frindModel];
}

- (void)setBadgesHidden:(BOOL)flag forFriendModel:(ZZFriendDomainModel *)friendModel
{
    [UIView animateWithDuration:0.2 animations:^{
        
        [[self.controller gridCellWithFriendModel:friendModel] setBadgesHidden:flag];
    }];
}

- (void)configureViewPositions
{
    __block NSMutableArray *filledGridModels = [NSMutableArray new];

    [self.items.copy enumerateObjectsUsingBlock:^(ZZGridCell *_Nonnull gridCell, NSUInteger idx, BOOL *_Nonnull stop) {
        
        [self.controller.initalFrames.copy enumerateObjectsUsingBlock:^(NSValue *_Nonnull rectValue, NSUInteger index, BOOL *_Nonnull stop) {
            
            CGRect rect = [rectValue CGRectValue];
            
            if (!CGRectIntersectsRect(rect, gridCell.frame))
            {
                return;
            }
            
            if (![gridCell respondsToSelector:@selector(model)])
            {
                return;
            }
            
            id model = [gridCell model];
            
            if (![model isKindOfClass:[ZZGridCellViewModel class]])
            {
                return;
            }
            
            ZZGridCellViewModel *cellModel = (ZZGridCellViewModel *)model;

            ZZGridDomainModel *item = cellModel.item;
            
            if (!item)
            {
                return;
            }
            
            item.index = kReverseIndexConvertation(index);
            
            [filledGridModels addObject:item];

        }];
    }];

    [self.eventHandler updatePositionForViewModels:filledGridModels];
}

- (NSInteger)indexOfBottomMiddleCell
{
    static NSArray <NSNumber *> *indexes;
    
    if (!indexes)
    {
        indexes = @[@1, @3, @5, @7, @6, @4, @0, @2];
    }
    
    NSUInteger offset = lroundf(self.gridView.calculatedCellsOffset / (2 * M_PI / 8));
    
    NSUInteger maxIndex = 7;
    
    if (offset > maxIndex)
    {
        offset = 0;
    }
    
    return indexes[offset].integerValue;
}

#pragma mark - GridView Event Delgate

- (void)updateRollingStateTo:(BOOL)isEnabled
{
    self.gridView.isRotationEnabled = isEnabled;
}

#pragma mark - Action Hadler User Interface Delegate

- (CGRect)focusFrameForIndex:(NSInteger)index
{
    return [self _frameForIndex:index];
}

- (UIView *)presentedView
{
    return self.view;
}

#pragma mark Private

- (CGRect)_frameForIndex:(NSInteger)index
{
    UIView *cell = [self _cellAdapterWithDependsOnIndex:index];
    CGRect position = [cell convertRect:cell.bounds toView:self.view];
    return position;
}

- (UIView *)_cellAdapterWithDependsOnIndex:(NSInteger)index
{
    __block UIView *cell = nil;;

    if (index != NSNotFound)
    {
        NSValue *indexRectValue = self.controller.initalFrames[index];
        CGRect indexRect = [indexRectValue CGRectValue];

        [self.items enumerateObjectsUsingBlock:^(UIView *_Nonnull view, NSUInteger idx, BOOL *_Nonnull stop) {
            if (CGRectIntersectsRect(indexRect, view.frame))
            {
                cell = view;
                *stop = YES;
            }
        }];
    }

    return cell;
}


#pragma mark - Touch Observer Delegate

- (void)stopPlaying
{
    [self.eventHandler stopPlaying];
}


#pragma mark - Update Record View State

- (void)updateRecordViewStateTo:(BOOL)isRecording
{
    NSInteger centerCellIndex = 4;
    
    ZZGridCenterCell *centerCell = self.gridView.items[centerCellIndex];
    
    [centerCell updateRecordStateTo:isRecording];
    
}

#pragma mark ZZTabbarViewItem

- (UIImage *)tabbarViewItemImage
{
    return [UIImage imageNamed:@"grid"];
}

@end

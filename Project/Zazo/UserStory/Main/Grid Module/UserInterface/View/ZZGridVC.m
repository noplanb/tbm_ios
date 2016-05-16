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
        frame.size.height -= 72; // tabbar

        self.gridView = [[ZZGridView alloc] initWithFrame:frame];
//        self.gridView.itemsContainerView.delegate = self;

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
    [self.view layoutIfNeeded];
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
//    [self.eventHandler stopPlaying];
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

- (void)menuWasOpened
{

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

- (void)showDimScreenForFriendModel:(ZZFriendDomainModel *)friendModel
{
    ZZGridCell *cell = [self cellForFriendModel:friendModel];
    NSUInteger index = [self.gridView.itemsContainerView.items indexOfObject:cell];

    if (index == NSNotFound)
    {
        return;
    }

//    [self.gridView.itemsContainerView showDimScreenForItemWithIndex:index];

    self.touchObserver.enabled = NO;
}

- (void)hideDimScreen
{
//    [self.gridView.itemsContainerView hideDimScreen];
    self.touchObserver.enabled = YES;
}

- (void)updateActiveCellTitleTo:(NSString *)title
{
    self.gridView.itemsContainerView.titleText = title;
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

- (void)configureViewPositions
{
    __block NSMutableArray *filledGridModels = [NSMutableArray new];

    [[self items] enumerateObjectsUsingBlock:^(ZZGridCell *_Nonnull gridCell, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.controller.initalFrames enumerateObjectsUsingBlock:^(NSValue *_Nonnull rectValue, NSUInteger index, BOOL *_Nonnull stop) {
            CGRect rect = [rectValue CGRectValue];
            if (CGRectIntersectsRect(rect, gridCell.frame))
            {
                if ([gridCell respondsToSelector:@selector(model)])
                {
                    id model = [gridCell model];
                    if ([model isKindOfClass:[ZZGridCellViewModel class]])
                    {
                        ZZGridCellViewModel *cellModel = (ZZGridCellViewModel *)model;
                        cellModel.item.index = kReverseIndexConvertation(index);
                        [filledGridModels addObject:cellModel.item];
                    }
                }
            }
        }];
    }];

    [self.eventHandler updatePositionForViewModels:filledGridModels];
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
    [centerCell updataeRecordStateTo:isRecording];
}

#pragma mark ZZTabbarViewItem

- (UIImage *)tabbarViewItemImage
{
    return [UIImage imageNamed:@"grid"];
}

#pragma mark ZZGridContainerViewDelegate

- (void)gridContainerViewDidTapOnDimView:(ZZGridContainerView *)containerView
{
    [self.eventHandler didTapOnDimView];
}

@end

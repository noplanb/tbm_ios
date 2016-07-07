//
//  ZZGridVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridVC.h"
#import "ZZGridView.h"
#import "ZZGridDataSource.h"
#import "ZZGridRotationTouchObserver.h"
#import "ZZGridUIConstants.h"
#import "ZZTabbarView.h"

@interface ZZGridVC () <ZZGridRotationTouchObserverDelegate, ZZGridCollectionControllerDelegate, UIGestureRecognizerDelegate, MenuOutput>

@property (nonatomic, strong) ZZGridView *gridView;
@property (nonatomic, strong) ZZGridRotationTouchObserver *touchObserver;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) Menu *menu;
@property (nonatomic, strong) NSString *overflowMenuFriendID;
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
        
        [self _makeTapRecognizer];
        
        _menu = [Menu new];
        _menu.output = self;
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

- (void)updateRotatingEnabled:(BOOL)enabled
{
    self.touchObserver.enabled = enabled;
    self.tapRecognizer.enabled = !enabled;
}

#pragma mark VC Interface

- (void)showOverflowMenuWithItems:(NSArray <MenuItem *> *)items
                         forModel:(ZZFriendDomainModel *)friendModel
{
    ZZGridCell *cell = (id)[self.controller gridCellWithFriendModel:friendModel];

    [self.menu showFrom:cell items:items];
    
    self.overflowMenuFriendID = friendModel.idTbm;
}

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
        
        NSUInteger index = [self _indexOfFrameForCell:gridCell];
        
        if (index == NSNotFound)
        {
            return;
        }
        
        ZZGridDomainModel *gridModel = [self _gridModelfromCell:gridCell];
        
        if (!gridModel)
        {
            return;
        }
        
        gridModel.index = index;
        
        [filledGridModels addObject:gridModel];

    }];

    [self.eventHandler updatePositionForViewModels:filledGridModels];
}

- (NSUInteger)_indexOfFrameForCell:(ZZGridCell *)gridCell
{
    __block NSUInteger index = NSNotFound;
    
    [self.controller.initalFrames.copy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect rect = [obj CGRectValue];
        
        if (CGRectIntersectsRect(rect, gridCell.frame))
        {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    if (index == NSNotFound)
    {
        return NSNotFound;
    }
    
    return kReverseIndexConvertation(index);
}

- (ZZGridDomainModel *)_gridModelfromCell:(ZZGridCell *)gridCell
{
    if (![gridCell respondsToSelector:@selector(model)])
    {
        return nil;
    }
    
    id model = [gridCell model];
    
    if (![model isKindOfClass:[ZZGridCellViewModel class]])
    {
        return nil;
    }
    
    ZZGridCellViewModel *cellModel = (ZZGridCellViewModel *)model;
    
    ZZGridDomainModel *item = cellModel.item;
    
    if (!item)
    {
        return nil;
    }
    
    return item;
}

- (NSInteger)indexOfBottomMiddleCell
{
    __block NSUInteger result = NSNotFound;

    [self.items.copy enumerateObjectsUsingBlock:^(ZZGridCell *_Nonnull gridCell, NSUInteger idx, BOOL *_Nonnull stop) {
        
        NSUInteger index = [self _indexOfFrameForCell:gridCell];
        
        if (index == 1) // position of bottom middle cell
        {
            result = [self _gridModelfromCell:gridCell].index;
        }
    }];
    
    return result;
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
    [self.controller updateInitialViewFramesIfNeeded];
    
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

#pragma mark Tap recognizer

- (void)_makeTapRecognizer
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.delegate = self;
    self.tapRecognizer.enabled = NO;
}

/**
 *  When the recognizer is enabled it intercept all taps, but passes long taps and other gestures.
 *
 *  @param recognizer
 */
- (void)_handleTap:(UITapGestureRecognizer *)recognizer
{
    [self.eventHandler stopPlaying];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark MenuOutput

- (void)eventFrom:(Menu * _Nonnull)menu didPick:(MenuItem * _Nonnull)item
{
    [self.eventHandler didTapOverflowMenuItem:item atFriendModelWithID:self.overflowMenuFriendID];
}

@end

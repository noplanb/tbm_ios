//
//  ZZTouchObserver.m
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZTouchObserver.h"
#import "ZZGridCollectionCell.h"
#import "ZZFakeRotationCell.h"

#import "ANSectionModel.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCellViewModel.h"

@interface ZZTouchObserver () <GridDelegate>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* movingViewArray;
@property (nonatomic, strong) NSMutableArray* initialStorageValue;
@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZMovingGridView* grid;
@property (nonatomic, assign) CGPoint touchPoint;

@end

@implementation ZZTouchObserver

- (instancetype)initWithGridView:(ZZGridView*)gridView
{
    self = [super init];
    if (self)
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
            for (id event in touches)
            {
                NSSet* touches = [event allTouches];
                UITouch* touch = [touches anyObject];
                [self observeTouch:touch withEvent:event];
            };
        }];
        
        self.movingViewArray = [NSMutableArray array];
        self.initialStorageValue = [NSMutableArray array];
        self.gridView = gridView;
        [self _createGridView];
    }
    
    return self;
}

- (void)hideMovedGridIfNeeded
{
    [self rotationStoped];
}

- (void)_createGridView
{
    if (!self.grid)
    {
        self.grid = [[ZZMovingGridView alloc] initWithFrame:self.collectionView.frame];
        
        self.grid.delegate = self;
        self.grid.hidden = YES;
        [self.gridView updateWithDelegate:self.grid];
        self.grid.rotationRecognizer = self.gridView.rotationRecognizer;
        [self.gridView addSubview:self.grid];
        
        [self.grid mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.gridView.collectionView);
        }];
    }
}

- (void)observeTouch:(UITouch *)touch withEvent:(id)event
{
    if (touch.phase == UITouchPhaseBegan)
    {
        self.initialLocation = [touch locationInView:self.gridView.collectionView];
        NSIndexPath* indexPath = [self.gridView.collectionView indexPathForItemAtPoint:self.initialLocation];
        UICollectionViewCell* cell = [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
        if (cell.isHidden && !self.grid.isHidden)
        {
            [self showMovingCell];
            self.grid.hidden = YES;
        }
      
    }
    
    if (self.grid.hidden && touch.phase == UITouchPhaseMoved && self.gridView.isRotationEnabled)
        {
            self.collectionView = self.gridView.collectionView;
            CGPoint location = [touch locationInView:self.gridView.collectionView];
            if (!self.isMoving)
            {
                self.isMoving = YES;
                self.initialLocation = location;
                
            }
            // start observer if touch start in cell
            NSIndexPath* indexPath = [self.gridView.collectionView indexPathForItemAtPoint:location];
            UICollectionViewCell* cell = [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
            if (cell)
            {
                [self startObserveWithTouch:touch withEvent:event withLocation:location];
            }
        }
}

- (void)startObserveWithTouch:(UITouch*)touch withEvent:(id)event withLocation:(CGPoint)location
{
    if (touch.phase == UITouchPhaseMoved)
    {
        // update grid view if it hidden
        if (self.grid.isHidden)
        {
            [self createMovingView];
            [self.grid removeAllCells];
            [self.grid setCells:self.movingViewArray];
            if (self.grid.isHidden)
            [self updateFakeViewImages];
            self.grid.alpha = 1.0;
            self.grid.hidden = NO;
            [self hideMovingCell];
        }
    }
}

- (NSArray *)fakeCellIndexes
{
    return @[@(0),@(1),@(2),@(5),@(8),@(7),@(6),@(3)];
}

- (void)updateFakeViewImages
{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ZZGridCollectionCell class]])
        {
            ZZGridCollectionCell* gridCell = (ZZGridCollectionCell*)obj;
            [gridCell makeActualScreenShoot];
            
            [self.movingViewArray enumerateObjectsUsingBlock:^(ZZFakeRotationCell* fakeCell, NSUInteger idx, BOOL *stop) {
                if (CGRectContainsPoint(gridCell.frame, fakeCell.center))
                {
                    fakeCell.stateImageView.image = [gridCell actualSateImage];
                    ZZGridCellViewModel* cellModel = [gridCell model];
                    [fakeCell updateBadgeWithNumber:cellModel.badgeNumber];
                }
            }];
        }
    }];
}

- (void)createMovingView
{
    [self.movingViewArray removeAllObjects];
    
    [[self fakeCellIndexes] enumerateObjectsUsingBlock:^(NSNumber* obj, NSUInteger idx, BOOL *stop) {
        ZZFakeRotationCell* moveView = [ZZFakeRotationCell new];
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:[obj integerValue] inSection:0];
        moveView.indexPath = indexPath;
        [self.movingViewArray addObject:moveView];
    }];
}

- (void)hideMovingCell
{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
        if ([cell isKindOfClass:[ZZGridCollectionCell class]])
        {
            cell.hidden = YES;
            ZZGridCollectionCell* gridCell = (ZZGridCollectionCell *)cell;
            [gridCell stopVideoPlaying];
        }
    }];
}

- (void)showMovingCell
{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
        if ([cell isKindOfClass:[ZZGridCollectionCell class]])
        {
            cell.hidden = NO;
        }
    }];
    
    [self.movingViewArray removeAllObjects];
}

#pragma mark - Grid delegate

- (void)rotationStoped
{   
    if (!self.grid.isHidden)
    {
        [self.initialStorageValue removeAllObjects];
        
        NSMutableDictionary* positionDict = [NSMutableDictionary dictionary];
        
        [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            
            if ([cell isKindOfClass:[ZZGridCollectionCell class]])
            {
                [self.movingViewArray enumerateObjectsUsingBlock:^(ZZFakeRotationCell* fakeCell, NSUInteger idx, BOOL *stop) {
                    if (CGRectIntersectsRect(cell.frame, fakeCell.frame))
                    {
                        NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
                        NSNumber* index = indexPath.item == 0 ? @(0) : @(indexPath.item);
                        [positionDict setObject:[self.storage itemAtIndexPath:fakeCell.indexPath] forKey:index];
                    }
                }];
            }
        }];
        
        [positionDict setObject:[self.storage itemAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:0]] forKey:@(4)];
        
        NSArray* arr = [[positionDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber* n in arr)
        {
            [self.initialStorageValue addObject:positionDict[n]];
        }
        
        [self.storage removeAllItems];
        [self.storage addItems:self.initialStorageValue];
        
        
        [UIView animateWithDuration:.13 animations:^{
            self.grid.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.grid.hidden = YES;
        }];
        
        [self showMovingCell];
    }
    
}

@end

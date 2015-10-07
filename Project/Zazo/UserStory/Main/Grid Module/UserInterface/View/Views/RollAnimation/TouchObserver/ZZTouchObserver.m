//
//  ZZTouchObserver.m
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZTouchObserver.h"
#import "ZZGridCell.h"
#import "ZZFakeRotationCell.h"

#import "ANSectionModel.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCellViewModel.h"
#import "ZZFeatureObserver.h"
#import "ZZRotator.h"

static CGFloat const kTouchOffset = 7;

@interface ZZTouchObserver () <GridDelegate>

@property (nonatomic, strong) NSMutableArray* movingViewArray;
@property (nonatomic, strong) NSMutableArray* initialStorageValue;
@property (nonatomic, assign) CGPoint initialLocation;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZMovingGridView* grid;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) BOOL isUpdatedAfterStart;

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
        
        self.grid = [ZZMovingGridView new];
        self.grid.delegate = self;
        self.grid.hidden = YES;
        
        [self.gridView updateWithDelegate:self.grid];
        
        self.grid.rotationRecognizer = self.gridView.rotationRecognizer;
        [self.gridView addSubview:self.grid];
        
        [self.grid mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.gridView.itemsContainerView);
        }];
    }
    return self;
}

//- (void)hideMovedGridIfNeeded
//{
//    [self rotationStoped];
//}

- (void)observeTouch:(UITouch *)touch withEvent:(id)event
{
    //    if ([ZZFeatureObserver sharedInstance].isSpinWeelEnabled)
    //    {
    if (touch.phase == UITouchPhaseBegan)
    {
        if (self.grid.isGridMoved)
        {
            
            //                [self.grid.rotator stopAnimationsOnGrid:self.grid];
            [self.grid.rotator stopDecayAnimationIfNeeded:self.grid.rotator.decayAnimation onGrid:self.grid];
            
        }
        else
        {
            self.initialLocation = [touch locationInView:self.gridView.itemsContainerView];
            UIView* cell = [self.gridView.itemsContainerView hitTest:self.initialLocation withEvent:nil];
            if (cell.isHidden && !self.grid.isHidden)
            {
                [self updateCellsHiddenStateTo:NO];
                self.grid.hidden = YES;
            }
        }
        
    }
    
    if (self.grid.hidden && touch.phase == UITouchPhaseMoved && self.gridView.isRotationEnabled && [self shouldMoveWithTouch:touch])
    {
        CGPoint location = [touch locationInView:self.gridView.itemsContainerView];
        [self.delegate stopPlaying];
        if (!self.isMoving)
        {
            self.isMoving = YES;
            self.initialLocation = location;
        }
        // start observer if touch start in cell
        UIView* cell = [self.gridView.itemsContainerView hitTest:location withEvent:nil];
        if (cell)
        {
            [self startObserveWithTouch:touch withEvent:event withLocation:location];
        }
    }
    //    }
}

- (BOOL)shouldMoveWithTouch:(UITouch*)touch
{
    BOOL shouldMove = NO;
    
    CGPoint location = CGPointZero;//[touch locationInView:self.gridView.collectionView];
    CGFloat midX;
    CGFloat midY;
    if (location.x > self.initialLocation.x)
    {
        midX = location.x - self.initialLocation.x;
    }
    else
    {
        midX = self.initialLocation.x - location.x;
    }
    
    
    if (location.y > self.initialLocation.y)
    {
        midY = location.y - self.initialLocation.y;
    }
    else
    {
        midY = self.initialLocation.y - location.y;
    }
    
    if (midY > kTouchOffset || midX > kTouchOffset)
    {
        shouldMove = YES;
    }
    
    return shouldMove;
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
            [self updateCellsHiddenStateTo:YES];
        }
    }
}

- (NSArray *)fakeCellIndexes
{
    return @[@(0),@(1),@(2),@(5),@(8),@(7),@(6),@(3)];
}

- (void)updateFakeViewImages
{
    [[self.gridView items] enumerateObjectsUsingBlock:^(UICollectionViewCell* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ZZGridCell class]])
        {
            ZZGridCell* gridCell = (ZZGridCell*)obj;
            
            [self.movingViewArray enumerateObjectsUsingBlock:^(ZZFakeRotationCell* fakeCell, NSUInteger idx, BOOL *stop) {
                if (CGRectContainsPoint(gridCell.frame, fakeCell.center))
                {
                    ZZGridCellViewModel* cellModel = [gridCell model];
                    [fakeCell updateBadgeWithNumber:cellModel.badgeNumber];
                    fakeCell.stateImageView.image = [self _screenshotFromView:gridCell];
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

- (void)updateCellsHiddenStateTo:(BOOL)isHidden
{
    [[self.gridView items] enumerateObjectsUsingBlock:^(UIView* cell, NSUInteger idx, BOOL *stop) {
        if ([cell isKindOfClass:[ZZGridCell class]])
        {
            cell.hidden = isHidden;
        }
    }];
    
    if (!isHidden)
    {
        [self.movingViewArray removeAllObjects];
    }
}


#pragma mark - Grid delegate

- (void)rotationStoped
{
    if (!self.grid.isHidden && !self.isUpdatedAfterStart)
    {
        self.isUpdatedAfterStart = YES;
        
        [self.initialStorageValue removeAllObjects];
        
        NSMutableDictionary* positionDict = [NSMutableDictionary dictionary];
        
        [[self.gridView items] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            
            if ([cell isKindOfClass:[ZZGridCell class]])
            {
                [self.movingViewArray enumerateObjectsUsingBlock:^(ZZFakeRotationCell* fakeCell, NSUInteger idx, BOOL *stop) {
                    if (CGRectIntersectsRect(cell.frame, fakeCell.frame))
                    {
                        if (cell)
                        {
                            NSInteger index = [[self.gridView items] indexOfObject:cell];
                            if (index != NSNotFound)
                            {
                                //                                [positionDict setObject:[self.storage itemAtIndexPath:fakeCell.indexPath] forKey:@(index)];//TODO:
                            }
                        }
                    }
                }];
            }
        }];
        
        //        [positionDict setObject:[self.storage itemAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:0]] forKey:@(4)]; // TODO:
        
        NSArray* arr = [[positionDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber* n in arr)
        {
            [self.initialStorageValue addObject:positionDict[n]];
        }
        //TODO:
        //        [UIView performWithoutAnimation:^{
        //            [self.storage removeAllItems];
        //            [self.storage addItems:self.initialStorageValue];
        //        }];
        
        [self updateCellsHiddenStateTo:NO];
        [UIView animateWithDuration:.2 animations:^{
            self.grid.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.grid.hidden = YES;
            self.isUpdatedAfterStart = NO;
        }];
    }
    
}

- (UIImage*)_screenshotFromView:(UIView*)view
{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end

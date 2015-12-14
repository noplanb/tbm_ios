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
#import "ZZActionSheetController.h"
#import "ZZGridUIConstants.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCellViewModel.h"

@interface ZZGridVC () <ZZGridRotationTouchObserverDelegate, ZZGridCollectionControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZGridCollectionController* controller;
@property (nonatomic, strong) ZZGridRotationTouchObserver* touchObserver;
@property (nonatomic, strong) UIPanGestureRecognizer* menuPanRecognizer;

@end

@implementation ZZGridVC

- (instancetype)init
{
    if (self = [super init])
    {
        self.gridView = [ZZGridView new];
        self.controller = [ZZGridCollectionController new];
        self.controller.delegate = self;
        
        self.touchObserver = [[ZZGridRotationTouchObserver alloc] initWithGridView:self.gridView];
        self.touchObserver.delegate = self;

        [[RACObserve(self.touchObserver, isMoving) filter:^BOOL(NSNumber* value) {
            return [value boolValue];
        }] subscribeNext:^(id x) {
            [self.eventHandler hideHintIfNeeded];
        }];
    }
    return self;
}

- (NSArray*)items
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
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
    
    self.gridView.headerView.menuButton.rac_command = [RACCommand commandWithBlock:^{
        [self menuSelected];
    }];
    
    self.gridView.headerView.editFriendsButton.rac_command = [RACCommand commandWithBlock:^{
        [self editFriendsSelected];
    }];
    
    self.menuPanRecognizer = [UIPanGestureRecognizer new];
    [self.view addGestureRecognizer:self.menuPanRecognizer];
    
    [self.eventHandler attachToMenuPanGesture:self.menuPanRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.controller updateInitialViewFramesIfNeeded];
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

- (void)showFriendAnimationWithFriendModel:(ZZFriendDomainModel *)friendModel
{
     ZZGridCell* animationCell = [self.controller gridCellWithFriendModel:friendModel];
    [animationCell showContainFriendAnimation];
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
    __block  NSMutableArray* filledGridModels = [NSMutableArray new];
    
    [[self items] enumerateObjectsUsingBlock:^(ZZGridCell*  _Nonnull gridCell, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.controller.initalFrames enumerateObjectsUsingBlock:^(NSValue*  _Nonnull rectValue, NSUInteger index, BOOL * _Nonnull stop) {
            CGRect rect = [rectValue CGRectValue];
            if (CGRectIntersectsRect(rect, gridCell.frame))
            {
                if([gridCell respondsToSelector:@selector(model)])
                {
                    id model = [gridCell model];
                    if ([model isKindOfClass:[ZZGridCellViewModel class]])
                    {
                        ZZGridCellViewModel* cellModel = (ZZGridCellViewModel*)model;
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

- (void)menuSelected
{
    [self.eventHandler presentMenu];
}

- (void)editFriendsSelected
{
    if (![self.eventHandler isRecordingInProgress])
    {
        
        [ZZActionSheetController actionSheetWithPresentedView:self.view
                                                        frame:self.gridView.headerView.editFriendsButton.frame
                                              completionBlock:^(ZZEditMenuButtonType selectedType) {
                                               
                                                  switch (selectedType)
                                                  {
                                                      case ZZEditMenuButtonTypeEditFriends:
                                                      {
                                                          [self.eventHandler presentEditFriendsController];
                                                      } break;
                                                          
                                                      case ZZEditMenuButtonTypeSendFeedback:
                                                      {
                                                          [self.eventHandler presentSendEmailController];
                                                      } break;
                                                      default: break;
                                                  }
                                              }];
    }
}

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
    UIView* cell = [self _cellAdapterWithDependsOnIndex:index];
    CGRect position = [cell convertRect:cell.bounds toView:self.view];
    return position;
}

- (UIView*)_cellAdapterWithDependsOnIndex:(NSInteger)index
{
    __block UIView* cell = nil;;
 
    if (index != NSNotFound)
    {
        NSValue* indexRectValue = self.controller.initalFrames[index];
        CGRect indexRect = [indexRectValue CGRectValue];
        
        [self.items enumerateObjectsUsingBlock:^(UIView*  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
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
    ZZGridCenterCell* centerCell = self.gridView.items[centerCellIndex];
    [centerCell updataeRecordStateTo:isRecording];
}

@end

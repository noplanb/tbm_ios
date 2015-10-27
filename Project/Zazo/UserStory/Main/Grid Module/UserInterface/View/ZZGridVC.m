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
#import "ZZTestGenerator.h"

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
    
    ZZTestGenerator* testGenerator = [ZZTestGenerator new];
    BOOL testResult = [testGenerator startTest];
    NSLog(@"stop test with resutl %d",testResult);
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

- (void)showFriendAnimationWithIndex:(NSInteger)index
{
    ZZGridCell* view = (ZZGridCell*)[self _cellAdapterWithDependsOnIndex:index];
    [view showContainFriendAnimation];
}

- (BOOL)isGridRotating
{
    return [self.touchObserver isGridRotate];
}

- (NSInteger)indexOfFriendModelOnGridView:(ZZFriendDomainModel *)frindModel
{
    return [self.controller indexOfFriendModelOnGrid:frindModel];
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

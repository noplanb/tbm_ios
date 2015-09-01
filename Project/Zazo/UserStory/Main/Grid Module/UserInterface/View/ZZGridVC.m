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
#import "ZZTouchObserver.h"
#import "Grid.h"

@interface ZZGridVC () <ZZGridCollectionControllerDelegate>

@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZGridCollectionController* controller;
@property (nonatomic, strong) ZZTouchObserver* touchObserver;

@end

@implementation ZZGridVC

- (instancetype)init
{
    if (self = [super init])
    {   
        self.gridView = [ZZGridView new];
        self.controller = [[ZZGridCollectionController alloc] initWithCollectionView:self.gridView.collectionView];
        self.controller.delegate = self;
        
        @weakify(self);
        [[self.gridView.menuButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
          @strongify(self);
            [self.eventHandler presentMenu];
        }];
        
        self.touchObserver =
        [[ZZTouchObserver alloc] initWithGridView:self.gridView];
    }
    
    return self;
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
}

- (void)udpateWithDataSource:(ZZGridDataSource *)dataSource
{
    self.controller.storage = dataSource.storage;
    self.touchObserver.storage = self.controller.storage;
}

- (void)menuIsOpened
{
    [self.touchObserver hideMovedGridIfNeeded];
}

- (void)showFriendAnimationWithModel:(ZZFriendDomainModel *)friendModel
{
    [self.controller showContainFriendAnimaionWithFriend:friendModel];
}

#pragma mark - Controller Delegate Method

- (void)selectedViewWithModel:(ZZGridCellViewModel *)model
{
    [self.eventHandler selectedCollectionViewWithModel:model];
}

- (id)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
}

@end

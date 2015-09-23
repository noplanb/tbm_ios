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
#import "ZZSoundPlayer.h"
#import "ZZFeatureObserver.h"
#import "ZZActionSheetController.h"


@interface ZZGridVC () <ZZTouchObserverDelegate>

@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZGridCollectionController* controller;
@property (nonatomic, strong) ZZTouchObserver* touchObserver;

@end

@implementation ZZGridVC

- (instancetype)init
{
    if (self = [super init])
    {
        [ZZFeatureObserver sharedInstance];
        self.gridView = [ZZGridView new];
        self.controller = [[ZZGridCollectionController alloc] initWithCollectionView:self.gridView.collectionView];
        self.touchObserver = [[ZZTouchObserver alloc] initWithGridView:self.gridView];
        self.touchObserver.delegate = self;
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
    
    self.gridView.headerView.menuButton.rac_command = [RACCommand commandWithBlock:^{
        [self menuSelected];
    }];
    
    self.gridView.headerView.editFriendsButton.rac_command = [RACCommand commandWithBlock:^{
        [self editFriendsSelected];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.eventHandler gridDidAppear];
}

- (void)updateWithDataSource:(ZZGridDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
    self.touchObserver.storage = dataSource.storage;
}

#pragma mark VC Interface

- (void)menuWasOpened
{
    
}

- (void)showFriendAnimationWithModel:(ZZFriendDomainModel *)friendModel
{
    [self.controller showContainFriendAnimaionWithFriend:friendModel];
}


#pragma mark - GridView Event Delgate

- (void)menuSelected
{
    [self.eventHandler presentMenu];
}

- (void)editFriendsSelected
{
    
    [ZZActionSheetController actionSheetWithPresentedView:self.view
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

- (void)updateRollingStateTo:(BOOL)isEnabled
{
    self.gridView.isRotationEnabled = isEnabled;
}


#pragma mark - Action Hadler User Interface Delegate

- (CGRect)focusFrameForIndex:(NSInteger)index
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell* cell = [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
    CGRect position = [cell convertRect:cell.contentView.bounds toView:self.view];
    
    return position;
}

- (void)updateSwitchButtonWithState:(BOOL)isHidden
{
    [self.gridView updateSwithCameraButtonWithState:isHidden];
}


#pragma mark - Touch Observer Delegate

- (void)stopPlaying
{
    [self.eventHandler stopPlaying];
}

@end

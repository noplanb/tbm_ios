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
#import "ZZGridVCDelegate.h"
#import "TBMBenchViewController.h"
#import "ZZSoundPlayer.h"

typedef NS_ENUM(NSInteger, ZZEditMenuButtonType) {
    ZZEditMenuButtonTypeEditFriends = 0,
    ZZEditMenuButtonTypeSendFeedback = 1,
    ZZEditMenuButtonTypeCancel = 2,
};

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
    [self.vcDelegate gridDidAppear];
}

- (void)updateWithDataSource:(ZZGridDataSource *)dataSource
{
    [self.controller updateDataSource:dataSource];
    self.touchObserver.storage = dataSource.storage;
}

#pragma mark VC Interface

- (UIView*)viewForDialogs
{
    return self.view;
}

- (CGRect)gridGetFrameForIndexPath:(NSIndexPath*)path inView:(UIView*)view
{
    CGRect rect = [self frameForIndexPath:path];
    CGRect result = [self.view convertRect:rect toView:view];
    return result;
}

- (CGRect)gridGetCenterCellFrameInView:(UIView*)view
{
    //TODO: (EventsFlow) Central cell frame
    //CGRect rect =
    //CGRect result = [self.view convertRect:rect toView:view];
    return CGRectZero;
}

- (CGRect)gridGetUnviewedBadgeFrameForIndexPath:(NSIndexPath*)path inView:(UIView*)view
{
    //TODO: (EventsFlow) Central cell frame
    //CGRect rect =
    //CGRect result = [self.view convertRect:rect toView:view];
    return CGRectZero;
}


- (void)menuWasOpened
{
    [self.touchObserver hideMovedGridIfNeeded];
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
    NSString *editFriendsButtonTitle = NSLocalizedString(@"grid-controller.menu.edit-friends.button.title", nil);
    NSString *sendFeedbackButtonTitle = NSLocalizedString(@"grid-controller.menu.send-feedback.button.title", nil);
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:nil
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:editFriendsButtonTitle, sendFeedbackButtonTitle, nil];
    [actionSheet showInView:self.view];
    
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber* x) {
       
        switch ([x integerValue])
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

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
    return cell.bounds;
}


#pragma mark - Touch Observer Delegate

- (void)stopPlaying
{
    [self.eventHandler stopPlaying];
}

@end

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
#import "ZZMovingGridView.h"
#import "TBMBenchViewController.h"
#import "ZZSoundPlayer.h"

typedef NS_ENUM(NSInteger, ZZEditMenuButtonType)
{
    ZZEditMenuButtonTypeEditFriends = 0,
    ZZEditMenuButtonTypeSendFeedback = 1,
    ZZEditMenuButtonTypeCancel = 2,
};

@interface ZZGridVC ()
<
  ZZGridCollectionControllerDelegate,
  ZZGridViewEventDelegate,
  UIActionSheetDelegate
>

@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZGridCollectionController* controller;
@property (nonatomic, strong) ZZTouchObserver* touchObserver;
@property (nonatomic, strong) ZZSoundPlayer* soundPlayer;

@end

@implementation ZZGridVC

- (instancetype)init
{
    if (self = [super init])
    {   
        self.gridView = [ZZGridView new];
        self.gridView.eventDelegate = self;
        self.controller = [[ZZGridCollectionController alloc] initWithCollectionView:self.gridView.collectionView];
        self.controller.delegate = self;

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
    self.soundPlayer = [[ZZSoundPlayer alloc] initWithSoundNamed:kMessageSoundEffectFileName];
}

- (void)playSound
{
    [self.soundPlayer play];
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

- (void)selectedViewWithModel:(ZZGridCollectionCellViewModel *)model
{
    [self.eventHandler selectedCollectionViewWithModel:model];
}

- (id)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
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
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:editFriendsButtonTitle, sendFeedbackButtonTitle, nil] showInView:self.view];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case ZZEditMenuButtonTypeEditFriends:
        {
            [self.eventHandler presentEditFriends];
        } break;
            
        case ZZEditMenuButtonTypeSendFeedback:
        {
            [self.eventHandler presentSendEmail];
        } break;
            
        case ZZEditMenuButtonTypeCancel:
        {
            
        } break;
            
        default:
            break;
    }
}

- (void)disableRolling
{
    [self.gridView disableViewRotation];
}

- (void)enableRolling
{
    [self.gridView enableViewRotation];
}

@end

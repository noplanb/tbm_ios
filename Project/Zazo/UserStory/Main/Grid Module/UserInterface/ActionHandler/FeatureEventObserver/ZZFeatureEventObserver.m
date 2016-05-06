//
//  ZZFeatureEventObserver.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventObserver.h"
#import "ZZFeatureEventStrategyBase.h"
#import "ZZFeatureEventStrategy.h"

@interface ZZFeatureEventObserver () <ZZFeatureEventStrategyDelegate>

@property (nonatomic, strong) ZZFeatureEventStrategyBase *strategy;

@end

@implementation ZZFeatureEventObserver


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _setupStrategy];
    }
    return self;
}


#pragma mark - Strategy Configuration

- (void)_setupStrategy
{
//    ZZUserDomainModel* authUser = [ZZUserDataProvider authenticatedUser];
//    
//    if (authUser.isInvitee)
//    {
    self.strategy = [ZZFeatureEventStrategy new];
    self.strategy.delegate = self;
//    }
//    else
//    {
//        self.strategy = [ZZFeatureEventStrategyRegisteredUser new];
//    }
}

- (void)updateFeaturesWithRemoteFriendMkeys:(NSArray *)friendMkeys
{
    [self.strategy updateFeaturesWithRemoteFriendsMkeys:friendMkeys];
}

- (void)handleEvent:(ZZGridActionEventType)event
          withModel:(ZZFriendDomainModel *)model
          withIndex:(NSInteger)index
withCompletionBlock:(void (^)(BOOL isFeatureShowed))completionBlock;
{
    if (event == ZZGridActionEventTypeMessageDidSent)
    {
        self.strategy.isFeatureShowed = NO;
        [self _handleBothCameraFeatureWithViewModel:model withIndex:index];
        [self _handleAbortRecordingWithDragWithViewModel:model withIndex:index];
        [self _handleDeleteFriendWithViewModel:model withIndex:index];
        [self _handleEventEarpieceWithViewModel:model withIndex:index];
        [self _handelSpinWheelEventWithModel:model withIndex:index];

        if (completionBlock)
        {
            completionBlock(self.strategy.isFeatureShowed);
        }
    }
}


#pragma mark - Event Strategy Delegate

- (void)showLastUnlockFeatureWithFeatureType:(ZZGridActionFeatureType)type friendModel:(ZZFriendDomainModel *)model
{
    switch (type)
    {
        case ZZGridActionFeatureTypeSwitchCamera:
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSwitchCamera withIndex:0 friendModel:model];
        }
            break;
        case ZZGridActionFeatureTypeAbortRec:
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeAbortRec withIndex:0 friendModel:model];
        }
            break;
        case ZZGridActionFeatureTypeDeleteFriend:
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeDeleteFriend withIndex:0 friendModel:model];
        }
            break;
        case ZZGridActionFeatureTypeEarpiece:
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeEarpiece withIndex:0 friendModel:model];
        }
            break;
        case ZZGridActionFeatureTypeSpinWheel:
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSpinWheel withIndex:0 friendModel:model];
        }
            break;
        default:
        {
        }
            break;
    }
}

#pragma mark - Both Camera handel event

- (void)_handleBothCameraFeatureWithViewModel:(ZZFriendDomainModel *)model withIndex:(NSInteger)index
{
    [self.strategy handleBothCameraFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSwitchCamera withIndex:index friendModel:model];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index friendModel:model];
        }
    }];
}


#pragma mark - Abort Recording Handle event

- (void)_handleAbortRecordingWithDragWithViewModel:(ZZFriendDomainModel *)model withIndex:(NSInteger)index
{
    [self.strategy handleAbortRecordingFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeAbortRec withIndex:index friendModel:model];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index friendModel:model];
        }
    }];
}


#pragma mark - Delete Friend handle event

- (void)_handleDeleteFriendWithViewModel:(ZZFriendDomainModel *)model withIndex:(NSInteger)index
{
    [self.strategy handleDeleteFriendFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeDeleteFriend withIndex:index friendModel:model];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index friendModel:model];
        }
    }];
}


#pragma mark - Handle Earpice event

- (void)_handleEventEarpieceWithViewModel:(ZZFriendDomainModel *)model withIndex:(NSInteger)index
{
    [self.strategy handleEarpieceFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeEarpiece withIndex:index friendModel:model];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index friendModel:model];
        }
    }];
}


- (void)_handelSpinWheelEventWithModel:(ZZFriendDomainModel *)model withIndex:(NSInteger)index
{
    [self.strategy handleSpinWheelFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSpinWheel withIndex:index friendModel:model];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index friendModel:model];
        }
    }];
}

@end

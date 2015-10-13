//
//  ZZFeatureEventObserver.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventObserver.h"
#import "ZZFeatureEventStrategyBase.h"
#import "ZZUserDataProvider.h"
#import "ZZFeatureEventStrategyInviteeUser.h"
#import "ZZFeatureEventStrategyRegisteredUser.h"

@interface ZZFeatureEventObserver ()

@property (nonatomic, strong) ZZFeatureEventStrategyBase* strategy;

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
          self.strategy = [ZZFeatureEventStrategyInviteeUser new];
//    }
//    else
//    {
//        self.strategy = [ZZFeatureEventStrategyRegisteredUser new];
//    }
}

- (void)handleEvent:(ZZGridActionEventType)event withModel:(ZZGridCellViewModel*)model withIndex:(NSInteger)index withCompletionBlock:(void(^)(BOOL isFeatureShowed))completionBlock;
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


#pragma mark - Both Camera handel event

- (void)_handleBothCameraFeatureWithViewModel:(ZZGridCellViewModel*)viewModel withIndex:(NSInteger)index
{
    [self.strategy handleBothCameraFeatureWithModel:viewModel withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSwitchCamera withIndex:index];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index];
        }
    }];
}


#pragma mark - Abort Recording Handle event

- (void)_handleAbortRecordingWithDragWithViewModel:(ZZGridCellViewModel*)model withIndex:(NSInteger)index
{
    [self.strategy handleAbortRecordingFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeAbortRec withIndex:index];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index];
        }
    }];
}


#pragma mark - Delete Friend handle event

- (void)_handleDeleteFriendWithViewModel:(ZZGridCellViewModel*)model withIndex:(NSInteger)index
{
    [self.strategy handleDeleteFriendFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
       if (isFeatureEnabled)
       {
           [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeDeleteFriend withIndex:index];
       }
       else
       {
           [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index];
       }
    }];
}


#pragma mark - Handle Earpice event

- (void)_handleEventEarpieceWithViewModel:(ZZGridCellViewModel*)model withIndex:(NSInteger)index
{
    [self.strategy handleEarpieceFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeEarpiece withIndex:index];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index];
        }
    }];
}


- (void)_handelSpinWheelEventWithModel:(ZZGridCellViewModel*)model withIndex:(NSInteger)index
{
    [self.strategy handleSpinWheelFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSpinWheel withIndex:index];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone withIndex:index];
        }
    }];
}

@end

//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"


@implementation ZZFeatureEventStrategyBase

- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleFullscreenFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    NSLog(@"base class");
}

- (void)handlePlaybackControlsFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    NSLog(@"base class");
}

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel *)viewModel beforeUnlockFeatureSentCount:(NSInteger)minimalMessageCount
{
    if (viewModel.isCreator)
    {
        return NO; // don't count this event if creator are not we
    }
    
    BOOL featureUnlocked = NO;
    
    EverSentHelper *helper = [EverSentHelper sharedInstance];

    BOOL isNewFriend = ![helper isEverSentToFriend:viewModel.mKey];
    
    [helper addToEverSent:viewModel.mKey];
    
    if (isNewFriend && helper.everSentCount >= minimalMessageCount) // we have sended messages enough to unlock this feature
    {
        self.featureUnlocked = YES;
        featureUnlocked = YES;
    }

    
    return featureUnlocked;
}

@end

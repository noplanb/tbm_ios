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
    //TODO: make assert this is base class!
}

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
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

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel *)viewModel beforeUnlockFeatureSentCount:(NSInteger)sentCount
{
    if (viewModel.isCreator)
    {
        return NO; // don't count this event if creator are not we
    }
    
    EverSentHelper *helper = [EverSentHelper sharedInstance];

    if (![helper isEverSentToFriend:viewModel.mKey] &&
         helper.everSentCount < sentCount)
    {
        self.isFeatureShowed = YES;
    }

    [helper addToEverSent:viewModel.mKey];
    
    return self.isFeatureShowed;
}

@end

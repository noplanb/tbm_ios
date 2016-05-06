//
//  ZZDeleteFriendsFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZDeleteFriendsFeatureEventHandler.h"

NSString *const ZZDeleteFriendsFeatureUnlockedNotificationName = @"ZZDeleteFriendsFeatureUnlockedNotificationName";

@implementation ZZDeleteFriendsFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel *)model
withCompletionBlock:(void (^)(ZZHintsType type, ZZFriendDomainModel *model))completionBlock
{
    if (event == ZZGridActionEventTypeDeleteFriendsFeatureUnlocked && ![ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
    {
        [ZZGridActionStoredSettings shared].deleteFriendHintWasShown = YES;

        [[NSNotificationCenter defaultCenter] postNotificationName:ZZDeleteFriendsFeatureUnlockedNotificationName object:nil];

        if (completionBlock)
        {
            completionBlock(ZZHintsTypeDeleteFriendUsageHint, model);
        }
    }
    else
    {
        if (!ANIsEmpty(self.eventHandler))
        {
            [super nextHandlerHandleEvent:event model:model withCompletionBlock:completionBlock];
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeNoHint, model);
            }
        }
    }
}

- (void)handleResetLastActionWithCompletionBlock:(void (^)(ZZGridActionEventType event, ZZFriendDomainModel *model))completionBlock
{
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end

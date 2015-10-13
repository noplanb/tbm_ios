//
//  ZZDeleteFriendsFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZDeleteFriendsFeatureEventHandler.h"

@implementation ZZDeleteFriendsFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeDeleteFriendsFeatureUnlocked && ![ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
    {
        [ZZGridActionStoredSettings shared].deleteFriendHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeDeleteFriendUsageHint, model);
        }
    }
    else
    {
        if(!ANIsEmpty(self.eventHandler))
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

- (void)handleResetLastActionWithCompletionBlock:(void (^)(ZZGridActionEventType, ZZGridCellViewModel *))completionBlock
{
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end

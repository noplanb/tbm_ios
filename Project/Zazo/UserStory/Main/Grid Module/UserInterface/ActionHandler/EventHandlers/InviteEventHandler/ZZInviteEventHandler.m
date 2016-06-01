//
//  ZZInviteEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZInviteEventHandler.h"

@implementation ZZInviteEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel *)model
withCompletionBlock:(void (^)(ZZHintsType type, ZZFriendDomainModel *model))completionBlock
{
    self.hintModel = model;

    if (event == ZZGridActionEventTypeGridLoaded &&
            [self.delegate friendsNumberOnGrid] == 0)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = YES;
        self.isLastActionDone = YES;

        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteHint, model);
        }

    }
    else if (event == ZZGridActionEventTypeDontHaveFriends)// && ![ZZGridActionStoredSettings shared].inviteHintWasShown)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = YES;
        self.isLastActionDone = YES;

        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteHint, model);
        }
    }
    else
    {
        self.hintModel = nil;
        self.isLastActionDone = NO;
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
    if (self.isLastActionDone)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = NO;
        self.isLastActionDone = NO;
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeDontHaveFriends, self.hintModel);
        }
    }
    else
    {
        if (self.eventHandler)
        {
            [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
        }
    }
}

@end

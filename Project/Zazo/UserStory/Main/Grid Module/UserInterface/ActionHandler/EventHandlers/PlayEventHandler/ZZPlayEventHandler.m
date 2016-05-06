//
//  ZZPlayEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZPlayEventHandler.h"
#import "ZZFriendDataHelper.h"

@implementation ZZPlayEventHandler


- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel *)model
withCompletionBlock:(void (^)(ZZHintsType type, ZZFriendDomainModel *model))completionBlock
{
    self.hintModel = model;
    if (event == ZZGridActionEventTypeGridLoaded &&
            [self.delegate friendsNumberOnGrid] == 1 &&
            [ZZFriendDataHelper unviewedVideoCountWithFriendID:model.idTbm] > 0 &&
            ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeBecomeMessage &&
            [self.delegate friendsNumberOnGrid] == 1 &&
            ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {

        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeBecomeMessage &&
            [self.delegate friendsNumberOnGrid] > 1 &&
            ![ZZGridActionStoredSettings shared].playHintWasShown &&
            ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {

        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }
    else
    {
        self.hintModel = nil;
        self.isLastAcitionDone = NO;
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
    if (self.isLastAcitionDone)
    {
        self.isLastAcitionDone = NO;
        [ZZGridActionStoredSettings shared].playHintWasShown = NO;
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeBecomeMessage, self.hintModel);
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

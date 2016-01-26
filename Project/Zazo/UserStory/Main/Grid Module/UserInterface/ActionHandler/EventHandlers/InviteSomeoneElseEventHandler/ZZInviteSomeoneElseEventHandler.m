//
//  ZZInviteSomeoneElseEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZInviteSomeoneElseEventHandler.h"
#import "ZZFriendDataHelper.h"

@implementation ZZInviteSomeoneElseEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock
{
    self.hintModel = model;
    if (event == ZZGridActionEventTypeSentZazo &&
            [self.delegate friendsNumberOnGrid] == 1 &&
        [ZZFriendDataHelper unviewedVideoCountWithFriendID:model.idTbm] > 0 &&
        ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeSentZazo &&
        ![ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown &&
            [self.delegate friendsNumberOnGrid] == 1 &&
        ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
//        self.isLastAcitionDone = YES;
        [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = YES;
        [ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteSomeElseHint, model);
        }
    }
    else  if (event == ZZGridActionEventTypeMessageDidSent &&
              ![ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession &&
            [self.delegate friendsNumberOnGrid] == 1 &&
              [ZZFriendDataHelper unviewedVideoCountWithFriendID:model.idTbm] == 0 &&
              ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
//        self.isLastAcitionDone = YES;
        [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteSomeElseHint, model);
        }
    }
    else  if (event == ZZGridActionEventTypeSentZazo &&
              ![ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown &&
            [self.delegate friendsNumberOnGrid] > 1)
    {
//        self.isLastAcitionDone = YES;
        [ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown = YES;
        [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }
    else
    {
        self.hintModel = nil;
        self.isLastAcitionDone = NO;
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

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZFriendDomainModel* model))completionBlock
{
    if (self.isLastAcitionDone)
    {
        self.isLastAcitionDone = NO;
        [ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown = NO;
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeSentZazo,self.hintModel);
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

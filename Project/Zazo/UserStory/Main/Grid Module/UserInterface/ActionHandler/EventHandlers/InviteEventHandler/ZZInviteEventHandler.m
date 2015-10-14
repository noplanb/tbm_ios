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
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    self.hintModel = model;

    if (event == ZZGridActionEventTypeGridLoaded &&
        [self.delegate frinedsNumberOnGrid] == 0)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = YES;
        self.isLastAcitionDone = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteHint, model);
        }
        
    }
    else if (event == ZZGridActionEventTypeDontHaveFriends)// && ![ZZGridActionStoredSettings shared].inviteHintWasShown)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = YES;
        self.isLastAcitionDone = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteHint, model);
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

- (void)handleResetLastActionWithCompletionBlock:(void (^)(ZZGridActionEventType, ZZGridCellViewModel *))completionBlock
{
    if (self.isLastAcitionDone)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = NO;
        self.isLastAcitionDone = NO;
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeDontHaveFriends,self.hintModel);
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

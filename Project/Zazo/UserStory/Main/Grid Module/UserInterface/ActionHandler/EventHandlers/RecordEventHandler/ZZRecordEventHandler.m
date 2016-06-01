//
//  ZZRecordEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRecordEventHandler.h"
#import "ZZFriendDataHelper.h"

@implementation ZZRecordEventHandler


- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel *)model
withCompletionBlock:(void (^)(ZZHintsType type, ZZFriendDomainModel *model))completionBlock
{
    if (event == ZZGridActionEventTypeGridLoaded &&
            [self.delegate friendsNumberOnGrid] == 1 &&
            [ZZFriendDataHelper unviewedVideoCountWithFriendID:model.idTbm] == 0 &&
            ![ZZGridActionStoredSettings shared].sentHintWasShown)
    {
        self.isLastActionDone = YES;
        self.hintModel = model;
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;

        CGFloat kDelayAfterViewLoaded = 0.8;
        ANDispatchBlockAfter(kDelayAfterViewLoaded, ^{
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeRecrodWelcomeHint, model);
            }
        });
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
            ![ZZGridActionStoredSettings shared].sentHintWasShown &&
            [self.delegate friendsNumberOnGrid] == 1)
    {
        self.hintModel = model;
        self.isLastActionDone = YES;

        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecrodWelcomeHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
            [self.delegate friendsNumberOnGrid] > 1)
    {
        self.isLastActionDone = YES;
        self.hintModel = model;
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;

        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }

    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
            ![ZZGridActionStoredSettings shared].recordHintWasShown &&
            [self.delegate friendsNumberOnGrid] == 1 &&
            ![ZZGridActionStoredSettings shared].sentHintWasShown)
    {
        self.isLastActionDone = YES;

        self.hintModel = model;

        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;

        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecordHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
            ![ZZGridActionStoredSettings shared].recordHintWasShown &&
            [self.delegate friendsNumberOnGrid] > 1)
    {
        self.isLastActionDone = YES;

        self.hintModel = model;

        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
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
        self.isLastActionDone = NO;
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = NO;

        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeGridLoaded, self.hintModel);
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

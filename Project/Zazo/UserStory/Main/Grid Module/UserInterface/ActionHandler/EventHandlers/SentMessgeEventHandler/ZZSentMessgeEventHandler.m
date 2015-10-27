//
//  ZZSentMessgeEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSentMessgeEventHandler.h"

@implementation ZZSentMessgeEventHandler


- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock
{
    if (event == ZZGridActionEventTypeMessageDidSent &&
        ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        model.unviewedCount > 0)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint,model);
        }
    
    }
    else if (event == ZZGridActionEventTypeMessageDidSent &&
        ![ZZGridActionStoredSettings shared].sentHintWasShown &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        model.unviewedCount == 0)
    {
        [ZZGridActionStoredSettings shared].sentHintWasShown = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeSentHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidSent &&
             ![ZZGridActionStoredSettings shared].sentHintWasShown &&
             [self.delegate frinedsNumberOnGrid] > 1)
    {
        [ZZGridActionStoredSettings shared].sentHintWasShown = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
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

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZFriendDomainModel* model))completionBlock
{
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end

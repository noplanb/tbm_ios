//
//  ZZSentWelcomeEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSentWelcomeEventHandler.h"

@implementation ZZSentWelcomeEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeFriendDidInvited)// &&
//        ![ZZGridActionStoredSettings shared].welcomeHintWasShown)
    {
        
         ZZHintsType type = ZZHintsTypeSendWelcomeHint;
        
        type = ZZHintsTypeSendWelcomeHint;
        if (![model.item.relatedUser hasApp])
        {
            type = ZZHintsTypeSendWelcomeHintForFriendWithoutApp;
        }
            
//        }
//        else if (launchCounter == 6)
//        {
//            [ZZGridActionStoredSettings shared].welcomeHintWasShown = YES;
//        }
    
        if (completionBlock)
        {
            completionBlock(type, model);
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

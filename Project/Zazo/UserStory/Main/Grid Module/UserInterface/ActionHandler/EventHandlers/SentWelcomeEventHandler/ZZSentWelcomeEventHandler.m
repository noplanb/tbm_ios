//
//  ZZSentWelcomeEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSentWelcomeEventHandler.h"

@implementation ZZSentWelcomeEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeFriendDidInvited && ![ZZGridActionStoredSettings shared].welcomeHintWasShown)
    {
        [ZZGridActionStoredSettings shared].welcomeHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeSendWelcomeHint);
        }
    }
    else
    {
        if(!ANIsEmpty(self.eventHandler))
        {
            [super nextHandlerHandleEvent:event withCompletionBlock:completionBlock];
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeNoHint);
            }
        }
    }
}

@end

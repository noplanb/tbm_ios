//
//  ZZInviteEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZInviteEventHandler.h"

@implementation ZZInviteEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeDontHaveFriends) //&& ![ZZGridActionStoredSettings shared].inviteHintWasShown)
    {
        [ZZGridActionStoredSettings shared].inviteHintWasShown = YES;
        
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteHint);
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

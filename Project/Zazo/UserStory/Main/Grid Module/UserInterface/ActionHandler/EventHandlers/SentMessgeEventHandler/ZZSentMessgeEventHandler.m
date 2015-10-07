//
//  ZZSentMessgeEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSentMessgeEventHandler.h"

@implementation ZZSentMessgeEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeMessageDidSent) //&& ![ZZGridActionStoredSettings shared].sentHintWasShown)
    {
        [ZZGridActionStoredSettings shared].sentHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeSentHint);
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

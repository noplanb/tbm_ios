//
//  ZZRecordEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRecordEventHandler.h"

@implementation ZZRecordEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeMessageDidPlayed && ![ZZGridActionStoredSettings shared].recordHintWasShown)
    {
        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecordHint);
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

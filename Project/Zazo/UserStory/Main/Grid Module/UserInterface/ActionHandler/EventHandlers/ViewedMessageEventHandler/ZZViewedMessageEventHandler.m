//
//  ZZViewedMessageEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZViewedMessageEventHandler.h"

@implementation ZZViewedMessageEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeMessageViewed && ![ZZGridActionStoredSettings shared].viewedHintWasShown)
    {
        [ZZGridActionStoredSettings shared].viewedHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeViewedHint);
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

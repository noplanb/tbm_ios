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
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeMessageDidSent &&
        ![ZZGridActionStoredSettings shared].sentHintWasShown &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        model.item.relatedUser.unviewedCount == 0)
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

- (void)handleResetLastActionWithCompletionBlock:(void (^)(ZZGridActionEventType, ZZGridCellViewModel *))completionBlock
{
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end

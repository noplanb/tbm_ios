//
//  ZZPlayEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZPlayEventHandler.h"

@implementation ZZPlayEventHandler


- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    
    if (event == ZZGridActionEventTypeBecomeMessage &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        ![ZZGridActionStoredSettings shared].playHintWasShown)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeBecomeMessage &&
             [self.delegate frinedsNumberOnGrid] > 1 &&
             ![ZZGridActionStoredSettings shared].playHintWasShown)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
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

@end

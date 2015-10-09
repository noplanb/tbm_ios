//
//  ZZRecordEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRecordEventHandler.h"

@implementation ZZRecordEventHandler


- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    
    if (event == ZZGridActionEventTypeMessageDidPlayed &&
        ![ZZGridActionStoredSettings shared].recordWelcomeHintWasShown &&
        [self.delegate frinedsNumberOnGrid] == 1)
    {
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecrodWelcomeHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             ![ZZGridActionStoredSettings shared].recordWelcomeHintWasShown &&
             [self.delegate frinedsNumberOnGrid] > 1)
    {
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }
    
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             ![ZZGridActionStoredSettings shared].recordHintWasShown &&
             [self.delegate frinedsNumberOnGrid] == 1)
    {
        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecordHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             ![ZZGridActionStoredSettings shared].recordHintWasShown &&
             [self.delegate frinedsNumberOnGrid] > 1)
    {
        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;
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

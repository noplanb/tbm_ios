//
//  ZZSpinFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSpinFeatureEventHandler.h"

@implementation ZZSpinFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeSpinUsageFeatureUnlocked && ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [ZZGridActionStoredSettings shared].spinHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeSpinUsageHint, model);
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
    NSLog(@"stop");
}

@end

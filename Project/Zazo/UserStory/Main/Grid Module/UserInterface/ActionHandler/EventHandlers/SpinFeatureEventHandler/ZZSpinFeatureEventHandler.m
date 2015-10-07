//
//  ZZSpinFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSpinFeatureEventHandler.h"

@implementation ZZSpinFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeSpinUsageFeatureUnlocked && ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [ZZGridActionStoredSettings shared].spinHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeSpinUsageHint);
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

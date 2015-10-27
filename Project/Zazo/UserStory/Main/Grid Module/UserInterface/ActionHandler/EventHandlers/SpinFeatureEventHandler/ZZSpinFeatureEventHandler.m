//
//  ZZSpinFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSpinFeatureEventHandler.h"

@implementation ZZSpinFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock
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

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZFriendDomainModel* model))completionBlock
{
    NSLog(@"stop");
}

@end

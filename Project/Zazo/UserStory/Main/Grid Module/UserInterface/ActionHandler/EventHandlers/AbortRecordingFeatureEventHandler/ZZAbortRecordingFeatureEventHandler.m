//
//  ZZAbortRecordingFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZAbortRecordingFeatureEventHandler.h"

@implementation ZZAbortRecordingFeatureEventHandler


- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock
{
    if (event == ZZGridActionEventTypeAbortRecordingFeatureUnlocked && ![ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        [ZZGridActionStoredSettings shared].abortRecordHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeAbortRecordingUsageHint, model);
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
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end

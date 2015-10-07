//
//  ZZAbortRecordingFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZAbortRecordingFeatureEventHandler.h"

@implementation ZZAbortRecordingFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeAbortRecordingFeatureUnlocked && ![ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        [ZZGridActionStoredSettings shared].abortRecordHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeAbortRecordingUsageHint);
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

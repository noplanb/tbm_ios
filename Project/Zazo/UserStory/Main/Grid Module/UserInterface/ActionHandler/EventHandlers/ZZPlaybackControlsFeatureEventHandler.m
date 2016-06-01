//
// Created by Rinat on 01/06/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZPlaybackControlsFeatureEventHandler.h"


@implementation ZZPlaybackControlsFeatureEventHandler
{

}

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel *)model
withCompletionBlock:(void (^)(ZZHintsType type, ZZFriendDomainModel *model))completionBlock
{
    if (event == ZZGridActionEventTypePlaybackControlsFeatureUnlocked && ![ZZGridActionStoredSettings shared].playbackControlsFeatureEnabled)
    {
        [ZZGridActionStoredSettings shared].playbackControlsFeatureEnabled = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlaybackControlsUsageHint, model);
        }
    }
    else
    {
        if (!ANIsEmpty(self.eventHandler))
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


- (void)handleResetLastActionWithCompletionBlock:(void (^)(ZZGridActionEventType event, ZZFriendDomainModel *model))completionBlock
{
    if (self.eventHandler)
    {
        [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
    }
}

@end
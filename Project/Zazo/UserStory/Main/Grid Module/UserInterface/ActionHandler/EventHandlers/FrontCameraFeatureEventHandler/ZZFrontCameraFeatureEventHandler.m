//
//  ZZFrontCameraFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFrontCameraFeatureEventHandler.h"

@implementation ZZFrontCameraFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock
{
    if (event == ZZGridActionEventTypeFrontCameraFeatureUnlocked && ![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        [ZZGridActionStoredSettings shared].frontCameraHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeFrontCameraUsageHint, model);
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

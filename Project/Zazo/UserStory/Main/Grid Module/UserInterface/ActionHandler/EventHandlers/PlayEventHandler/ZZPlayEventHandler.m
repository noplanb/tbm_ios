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
    self.hintModel = model;
    if (event == ZZGridActionEventTypeGridLoaded &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        model.item.relatedUser.unviewedCount > 0 &&
        ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeBecomeMessage &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
         ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {
        
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypePlayHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeBecomeMessage &&
             [self.delegate frinedsNumberOnGrid] > 1 &&
             ![ZZGridActionStoredSettings shared].playHintWasShown &&
             ![ZZGridActionStoredSettings shared].incomingVideoWasPlayed)
    {
        
        [ZZGridActionStoredSettings shared].playHintWasShown = YES;
        self.isLastAcitionDone = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }
    else
    {
        self.hintModel = nil;
         self.isLastAcitionDone = NO;
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
    if (self.isLastAcitionDone)
    {
        self.isLastAcitionDone = NO;
        [ZZGridActionStoredSettings shared].playHintWasShown = NO;
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeBecomeMessage,self.hintModel);
        }
    }
    else
    {
        if (self.eventHandler)
        {
            [self.eventHandler handleResetLastActionWithCompletionBlock:completionBlock];
        }
    }
}

@end

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
    if (event == ZZGridActionEventTypeGridLoaded &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        model.item.relatedUser.unviewedCount == 0 &&
        ![ZZGridActionStoredSettings shared].sentHintWasShown)
    {
        self.isLastAcitionDone = YES;
        self.hintModel = model;
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
        
        CGFloat kDelayAfterViewLoaded = 0.8;
        ANDispatchBlockAfter(kDelayAfterViewLoaded, ^{
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeRecrodWelcomeHint, model);
            }
        });
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             ![ZZGridActionStoredSettings shared].sentHintWasShown &&
             [self.delegate frinedsNumberOnGrid] == 1)
    {
        self.hintModel = model;
        self.isLastAcitionDone = YES;
       
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeRecrodWelcomeHint, model);
        }
    }
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             [self.delegate frinedsNumberOnGrid] > 1)
    {
        self.isLastAcitionDone = YES;
        self.hintModel = model;
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = YES;
     
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeNoHint, model);
        }
    }
    
    else if (event == ZZGridActionEventTypeMessageDidPlayed &&
             ![ZZGridActionStoredSettings shared].recordHintWasShown &&
             [self.delegate frinedsNumberOnGrid] == 1 &&
             ![ZZGridActionStoredSettings shared].sentHintWasShown)
    {
        self.isLastAcitionDone = YES;

        self.hintModel = model;
        
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
        self.isLastAcitionDone = YES;

        self.hintModel = model;
        
        [ZZGridActionStoredSettings shared].recordHintWasShown = YES;
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
        [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = NO;
        
        
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeGridLoaded,self.hintModel);
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

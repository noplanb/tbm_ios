//
//  ZZRecordEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRecordEventHandler.h"

@interface ZZRecordEventHandler ()

@property (nonatomic, assign) BOOL isWelcomeRecordShown;
@property (nonatomic, assign) BOOL isRecordWasShown;

@end


@implementation ZZRecordEventHandler


- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeGridLoaded &&
        [self.delegate frinedsNumberOnGrid] == 1 &&
        ![ZZGridActionStoredSettings shared].recordWelcomeHintWasShown)
    {
        self.isLastAcitionDone = YES;
        self.isWelcomeRecordShown = YES;
        self.isRecordWasShown = NO;
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
        ![ZZGridActionStoredSettings shared].recordWelcomeHintWasShown &&
        [self.delegate frinedsNumberOnGrid] == 1)
    {
        self.hintModel = model;
        self.isLastAcitionDone = YES;
        self.isWelcomeRecordShown = YES;
        self.isRecordWasShown = NO;
        
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
        self.isLastAcitionDone = YES;
        self.isWelcomeRecordShown = YES;
        self.isRecordWasShown = NO;
        self.hintModel = model;
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
        self.isLastAcitionDone = YES;
        self.isWelcomeRecordShown = NO;
        self.isRecordWasShown = YES;
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
        self.isWelcomeRecordShown = NO;
        self.isRecordWasShown = YES;
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
        [self _resetAllActionsMarker];
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
        if (self.isWelcomeRecordShown)
        {
            [self _resetAllActionsMarker];
            [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = NO;
            
        }
        else
        {
            [self _resetAllActionsMarker];
            [ZZGridActionStoredSettings shared].recordHintWasShown = NO;
        }
        
        if (completionBlock)
        {
            completionBlock(ZZGridActionEventTypeMessageDidPlayed,self.hintModel);
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

- (void)_resetAllActionsMarker
{
    self.isLastAcitionDone = NO;
    self.isWelcomeRecordShown = NO;
    self.isRecordWasShown = NO;
}

@end

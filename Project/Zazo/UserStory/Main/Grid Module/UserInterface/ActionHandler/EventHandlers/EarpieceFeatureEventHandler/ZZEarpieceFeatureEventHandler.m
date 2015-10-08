//
//  ZZEarpieceFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZEarpieceFeatureEventHandler.h"

@implementation ZZEarpieceFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeEarpieceFeatureUnlocked && ![ZZGridActionStoredSettings shared].earpieceHintWasShown)
    {
        [ZZGridActionStoredSettings shared].earpieceHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeEarpieceUsageHint, model);
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

@end

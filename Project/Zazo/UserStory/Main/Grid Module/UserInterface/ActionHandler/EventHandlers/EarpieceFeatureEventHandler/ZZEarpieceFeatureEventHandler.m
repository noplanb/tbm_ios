//
//  ZZEarpieceFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZEarpieceFeatureEventHandler.h"

@implementation ZZEarpieceFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeEarpieceFeatureUnlocked && ![ZZGridActionStoredSettings shared].earpieceHintWasShown)
    {
        [ZZGridActionStoredSettings shared].earpieceHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeEarpieceUsageHint);
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

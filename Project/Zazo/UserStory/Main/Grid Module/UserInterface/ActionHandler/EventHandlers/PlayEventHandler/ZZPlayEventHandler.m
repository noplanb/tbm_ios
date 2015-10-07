//
//  ZZPlayEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZPlayEventHandler.h"

@implementation ZZPlayEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
     if (event == ZZGridActionEventTypeBecomeMessage && ![ZZGridActionStoredSettings shared].playHintWasShown)
     {
         [ZZGridActionStoredSettings shared].playHintWasShown = YES;
         if (completionBlock)
         {
             completionBlock(ZZHintsTypePlayHint);
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

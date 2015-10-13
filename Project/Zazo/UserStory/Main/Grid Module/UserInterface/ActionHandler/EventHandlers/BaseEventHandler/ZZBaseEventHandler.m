//
//  ZZBaseEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZBaseEventHandler.h"

@implementation ZZBaseEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZGridCellViewModel* model))completionBlock
{
    NSLog(@"base class");
}

- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event
                         model:(ZZGridCellViewModel*)model
           withCompletionBlock:(void(^)(ZZHintsType handledEvent, ZZGridCellViewModel* model))completionBlock
{
    [self.eventHandler handleEvent:event model:model withCompletionBlock:completionBlock];
}

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZGridCellViewModel* model))completionBlock
{
    NSAssert(false, @"This is base class");
}

@end

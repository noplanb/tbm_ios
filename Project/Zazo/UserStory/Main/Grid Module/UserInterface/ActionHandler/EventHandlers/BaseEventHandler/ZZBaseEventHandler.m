//
//  ZZBaseEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZBaseEventHandler.h"

@implementation ZZBaseEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType))completionBlock
{
    NSLog(@"base class");
}


- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event withCompletionBlock:(void(^)(ZZHintsType handledEvent))completionBlock
{
    [self.eventHandler handleEvent:event withCompletionBlock:completionBlock];
}

@end

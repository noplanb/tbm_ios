//
//  ZZBaseEventHandler.h
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZGridActionHandlerEnums.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZHintsConstants.h"

@interface ZZBaseEventHandler : NSObject

@property (nonatomic, strong) ZZBaseEventHandler* eventHandler;

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void(^)(ZZHintsType type))completionBlock;
- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event withCompletionBlock:(void(^)(ZZHintsType handledEvent))completionBlock;

@end

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
#import "ZZGridCellViewModel.h"

@interface ZZBaseEventHandler : NSObject

@property (nonatomic, strong) ZZBaseEventHandler* eventHandler;

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZGridCellViewModel* model))completionBlock;

- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event
                         model:(ZZGridCellViewModel*)model
           withCompletionBlock:(void(^)(ZZHintsType handledEvent, ZZGridCellViewModel* model))completionBlock;

@end

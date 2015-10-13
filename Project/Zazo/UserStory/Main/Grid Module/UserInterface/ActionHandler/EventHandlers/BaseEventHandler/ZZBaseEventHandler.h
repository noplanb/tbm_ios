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
#import "ZZGridDomainModel.h"


@protocol ZZEventHandlerDelegate <NSObject>

- (NSInteger)frinedsNumberOnGrid;

@end


@interface ZZBaseEventHandler : NSObject

@property (nonatomic, strong) ZZBaseEventHandler* eventHandler;
@property (nonatomic, weak) id <ZZEventHandlerDelegate> delegate;
@property (nonatomic, assign) BOOL isLastAcitionDone;
@property (nonatomic, strong) ZZGridCellViewModel* hintModel;

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZGridCellViewModel* model))completionBlock;

- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event
                         model:(ZZGridCellViewModel*)model
           withCompletionBlock:(void(^)(ZZHintsType handledEvent, ZZGridCellViewModel* model))completionBlock;

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZGridCellViewModel* model))completionBlock;

@end

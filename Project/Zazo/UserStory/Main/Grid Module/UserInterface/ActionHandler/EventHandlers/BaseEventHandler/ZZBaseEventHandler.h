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
#import "ZZGridDomainModel.h"

@protocol ZZEventHandlerDelegate <NSObject>

- (NSInteger)frinedsNumberOnGrid;

@end


@interface ZZBaseEventHandler : NSObject

@property (nonatomic, strong) ZZBaseEventHandler* eventHandler;
@property (nonatomic, weak) id <ZZEventHandlerDelegate> delegate;
@property (nonatomic, assign) BOOL isLastAcitionDone;
@property (nonatomic, strong) ZZFriendDomainModel* hintModel;

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZFriendDomainModel*)model
withCompletionBlock:(void(^)(ZZHintsType type, ZZFriendDomainModel* model))completionBlock;

- (void)nextHandlerHandleEvent:(ZZGridActionEventType)event
                         model:(ZZFriendDomainModel*)model
           withCompletionBlock:(void(^)(ZZHintsType handledEvent, ZZFriendDomainModel* model))completionBlock;

- (void)handleResetLastActionWithCompletionBlock:(void(^)(ZZGridActionEventType event, ZZFriendDomainModel* model))completionBlock;

@end

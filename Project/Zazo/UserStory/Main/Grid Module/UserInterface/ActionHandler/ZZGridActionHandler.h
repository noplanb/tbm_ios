//
//  ZZGridActionHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"
#import "ZZGridActionHandlerUserInterfaceDelegate.h"

@class ZZHintsDomainModel;

@protocol ZZGridActionHanlderDelegate <NSObject>

- (void)unlockFeature:(ZZGridActionFeatureType)feature;

@end

@interface ZZGridActionHandler : NSObject

@property (nonatomic, weak) id<ZZGridActionHanlderDelegate> delegate;
@property (nonatomic, weak) id<ZZGridActionHanlderUserInterfaceDelegate> userInterface;

- (void)handleEvent:(ZZGridActionEventType)event;

@end

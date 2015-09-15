//
//  ZZGridActionHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"

@protocol ZZGridActionHanlderDelegate <NSObject>

- (void)unlockFeature:(ZZGridActionFeatureType)feature;

@end

@interface ZZGridActionHandler : NSObject

@property (nonatomic, weak) id<ZZGridActionHanlderDelegate> delegate;

- (void)handleEvent:(ZZGridActionEventType)event;

@end

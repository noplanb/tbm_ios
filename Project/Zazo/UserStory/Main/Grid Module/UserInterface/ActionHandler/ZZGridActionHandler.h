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
@class ZZGridCellViewModel;

@protocol ZZGridActionHanlderDelegate <NSObject>

- (void)unlockedFeature:(ZZGridActionFeatureType)feature;
- (id)modelAtIndex:(NSInteger)index;
- (BOOL)isVideoPlayingNow;
- (NSInteger)friendsCountOnGrid;

@end

@interface ZZGridActionHandler : NSObject

@property (nonatomic, weak) id<ZZGridActionHanlderDelegate> delegate;
@property (nonatomic, weak) id<ZZGridActionHanlderUserInterfaceDelegate> userInterface;

- (void)handleEvent:(ZZGridActionEventType)event withIndex:(NSInteger)index;
- (void)resetLastHintAndShowIfNeeded;

@end

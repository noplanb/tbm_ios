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
@class ZZFriendDomainModel;

@protocol ZZGridActionHanlderDelegate <NSObject>

- (void)unlockedFeature:(ZZGridActionFeatureType)feature;

- (BOOL)isVideoPlayingNow;

- (NSInteger)friendsCountOnGrid;

- (void)showMenuTab;

- (void)showGridTab;

- (UIView *)presentedView;

@end

@interface ZZGridActionHandler : NSObject

@property (nonatomic, weak) id <ZZGridActionHanlderDelegate> delegate;
@property (nonatomic, weak) id <ZZGridActionHanlderUserInterfaceDelegate> userInterface;

- (void)handleEvent:(ZZGridActionEventType)event
          withIndex:(NSInteger)index
        friendModel:(ZZFriendDomainModel *)friendModel;

- (void)resetLastHintAndShowIfNeeded;

- (void)hideHint;

- (void)updateFeaturesWithFriendsMkeys:(NSArray *)friendsMkeys;

@end

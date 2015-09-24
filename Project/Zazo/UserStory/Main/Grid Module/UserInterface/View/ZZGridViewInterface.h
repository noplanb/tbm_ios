//
//  ZZGridViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridActionHandlerUserInterfaceDelegate.h"

@class ZZGridDataSource;
@class ZZFriendDomainModel;

@protocol ZZGridViewInterface <ZZGridActionHanlderUserInterfaceDelegate>

- (void)updateWithDataSource:(ZZGridDataSource*)dataSource;
- (void)showFriendAnimationWithModel:(ZZFriendDomainModel*)friendModel;
- (void)updateRollingStateTo:(BOOL)isEnabled;
- (void)menuWasOpened;
- (void)updateSwitchButtonWithState:(BOOL)isHidden;
- (void)updateLoadingStateTo:(BOOL)isLoading;

@end

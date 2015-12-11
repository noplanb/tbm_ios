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
//@class ZZGridCellViewModel;
//@class ZZGridDomainModel;

@protocol ZZGridViewInterface <ZZGridActionHanlderUserInterfaceDelegate>

- (void)updateWithDataSource:(ZZGridDataSource*)dataSource;
- (void)showFriendAnimationWithFriendModel:(ZZFriendDomainModel*)friendModel;

- (void)updateRollingStateTo:(BOOL)isEnabled;
- (void)menuWasOpened;
- (void)updateLoadingStateTo:(BOOL)isLoading;
- (void)updateRecordViewStateTo:(BOOL)isRecording;
- (BOOL)isGridRotating;
- (NSInteger)indexOfFriendModelOnGridView:(ZZFriendDomainModel*)friendModel;
- (void)configureViewPositions;

@end

//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel;

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)presentEditFriendsController;
- (void)presentSendEmailController;
- (void)stopPlaying;

// Hints appearance
- (UIView*)viewForDialog;
- (CGRect)gridGetFrameForFriend:(NSUInteger)friendCellIndex inView:(UIView*)view;
- (CGRect)gridGetCenterCellFrameInView:(UIView*)view;
- (CGRect)gridGetFrameForUnviewedBadgeForFriend:(NSUInteger)friendCellIndex inView:(UIView*)view;
- (NSUInteger)lastAddedFriendOnGridIndex;
- (NSString*)lastAddedFriendOnGridName;
- (BOOL)isRecordingInProgress;

@end

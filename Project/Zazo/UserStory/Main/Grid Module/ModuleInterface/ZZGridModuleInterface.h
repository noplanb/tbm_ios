//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)presentEditFriendsController;
- (void)presentSendEmailController;
- (void)stopPlaying;

- (BOOL)isRecordingInProgress;
- (void)attachToMenuPanGesture:(UIPanGestureRecognizer*)pan;
- (void)hideHintIfNeeded;
- (void)updatePositionForViewModels:(NSArray*)models;

@end

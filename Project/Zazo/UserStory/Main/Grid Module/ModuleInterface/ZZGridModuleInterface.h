//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel;

@protocol ZZGridModuleInterface <NSObject>

- (void)didTapOverflowMenuItem:(MenuItem *)item atFriendModelWithID:(NSString *)friendID;

- (void)presentMenu;

- (void)stopPlaying;

- (BOOL)isRecordingInProgress;

- (void)hideHintIfNeeded;

- (void)updatePositionForViewModels:(NSArray *)models;

- (CGRect)frameOfViewForFriendModelWithID:(NSString *)friendID; // return friend's view frame relative to parent window

@end

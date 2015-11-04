//
//  ZZGridDataSourceInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/2/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZGridCellViewModel;

@protocol ZZGridDataSourceControllerDelegate <NSObject>

- (void)reload;
- (void)reloadItemAtIndex:(NSInteger)index;
- (void)reloadItem:(id)item;

@end

@protocol ZZGridDataSourceDelegate <NSObject>

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(ZZBoolBlock)completionBlock;
- (void)cancelRecordingWithReason:(NSString *)reason;

- (void)toggleVideoWithViewModel:(ZZGridCellViewModel*)model toState:(BOOL)state;
- (void)nudgeSelectedWithUserModel:(id)userModel;
- (void)showHint;
- (void)switchCamera;
- (BOOL)isVideoPlaying;
- (void)addUser;
- (BOOL)isGridRotate;

@end

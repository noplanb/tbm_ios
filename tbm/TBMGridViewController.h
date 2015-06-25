//
//  TBMGridViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 12/10/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMAppDelegate.h"
#import <UIKit/UIKit.h>
#import "TBMFriend.h"
#import "TBMLongPressTouchHandler.h"
#import "TBMVideoRecorder.h"
#import "TBMGridModuleInterface.h"
#import "TBMGridElementDelegate.h"

@protocol TBMGridDelegate;


@interface TBMGridViewController : UIViewController <TBMGridElementDelegate, TBMGridModuleInterface, TBMLongPressTouchHandlerCallback, TBMVideoRecorderDelegate, TBMAppDelegateEventNotificationProtocol, TBMVideoStatusNotificationProtocol>

@property(nonatomic, weak) id <TBMGridDelegate> delegate;
/**
 * Its fix for grid, will replaced when it will refactored
 */
@property(nonatomic, assign) CGRect frame;

- (NSMutableArray *)friendsOnGrid;
- (NSMutableArray *)friendsOnBench;
- (void)moveFriendToGrid:(TBMFriend *)friend;
- (void)rankingActionOccurred:(TBMFriend *)friend;
- (BOOL)isRecording;


@end

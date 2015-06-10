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

@protocol TBMGridDelegate;


@interface TBMGridViewController : UIViewController <TBMLongPressTouchHandlerCallback, TBMVideoRecorderDelegate, TBMAppDelegateEventNotificationProtocol, TBMVideoStatusNotificationProtocol>

@property(nonatomic, weak) id <TBMGridDelegate> delegate;

- (NSMutableArray *)friendsOnGrid;
- (NSMutableArray *)friendsOnBench;
- (void)moveFriendToGrid:(TBMFriend *)friend;
- (void)rankingActionOccurred:(TBMFriend *)friend;
- (BOOL)isRecording;


- (NSUInteger)unviewedCount;

- (CGRect)frameForFirstFriendBadgeInView:(UIView *)view;

- (CGRect)frameForFirstFriendInView:(UIView *)view;
@end

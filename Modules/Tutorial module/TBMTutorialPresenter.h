//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMHintDelegate.h"
#import "TBMTutorialModuleInterface.h"

@class TBMHint;

@protocol TBMGridModuleInterface;

@interface TBMTutorialPresenter : NSObject <TBMHintDelegate,TBMTutorialModuleInterface>

@property(nonatomic, strong) UIView *parentView;

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

/**
 * Initialize tutorial module, not present it
 */
- (instancetype)initWithSuperview:(UIView *)parentView;

/**
 * Reseting session
 */
- (void)resetSession;

/**
 * Events
 *
 * Parent modules send signals about application state and flow
 */
- (void)applicationDidLaunch;

- (void)applicationDidEnterBackground;

- (void)friendDidAdd;

- (void)messageDidReceive;

- (void)messageDidSend;

- (void)messageDidStartPlaying;

- (void)messageDidStopPlaying;

- (void)messageDidStartRecording;

- (void)messageDidRecorded;

- (void)messageDidViewed:(NSUInteger)gridIndex;

@end
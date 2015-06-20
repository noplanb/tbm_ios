//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMHint;

@protocol TBMGridModuleInterface;

@interface TBMTutorialPresenter : NSObject

@property(nonatomic, strong) UIView *parentView;

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

/**
 * Initialize tutorial module, not present it
 */
- (instancetype)initWithSuperview:(UIView *)parentView;

/**
 * Events
 *
 * Parent modules send signals about application state and flow
 */
- (void)applicationDidLaunch;

- (void)friendDidAdd;

- (void)friendDidInvite;

- (void)messageDidReceive;

- (void)messageDidSend;

- (void)messageDidPlay;

- (void)messageDidRecorded;

- (void)messageDidViewed;
@end
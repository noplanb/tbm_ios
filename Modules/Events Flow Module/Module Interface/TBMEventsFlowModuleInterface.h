//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridModuleInterface;
@protocol TBMEventsFlowModuleEventHandler;


/**
 * Enum of possible events fo throwEvent:
 */
typedef NS_ENUM(NSInteger, TBMEventFlowEvent) {
    TBMEventFlowEventNone,

    // Application events
            TBMEventFlowEventApplicationDidLaunch,
    TBMEventFlowEventApplicationDidEnterBackground,

    // Friend events
            TBMEventFlowEventFriendDidAdd,

    // Messages events
            TBMEventFlowEventMessageDidReceive,
    TBMEventFlowEventMessageDidSend,
    TBMEventFlowEventMessageDidStartPlaying,
    TBMEventFlowEventMessageDidStopPlaying,
    TBMEventFlowEventMessageDidStartRecording,
    TBMEventFlowEventMessageDidRecorded,
    TBMEventFlowEventMessageDidViewed,

    // Hints events
            TBMEventFlowEventSentHintDidDismiss,

    // Feature unlocks events

    // Next Feature dialogs events
};


@protocol TBMEventsFlowModuleInterface <NSObject>

/**
 * Setup grid module for hints
 */
- (void)setupGridModule:(id <TBMGridModuleInterface>)gridModule;

/**
 * States of event handlers
 */
- (void)resetSession;

- (void)resetHintsState;

- (void)resetFeaturesState;

/**
 * Add an event handler e.g. hint, dialog etc.
 */
- (void)addEventHandler:(id <TBMEventsFlowModuleEventHandler>)eventHandler;

/**
 * Events happens
 *
 * Parent modules send signals about application state and flow
 */


- (void)throwEvent:(TBMEventFlowEvent)anEvent;

- (BOOL)isAnyHandlerActive;

- (BOOL)isRecording;

- (id <TBMEventsFlowModuleEventHandler>)currentHandler;
@end
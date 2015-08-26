//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridModuleInterface;
@protocol TBMEventsFlowModuleEventHandler;


/**
 * Enum of possible events for throwEvent:
 */
typedef NS_ENUM(NSInteger, TBMEventFlowEvent)
{
    TBMEventFlowEventNone,

    // Application

    TBMEventFlowEventApplicationDidLaunch,
    TBMEventFlowEventApplicationDidEnterBackground,

    // Friends

    TBMEventFlowEventFriendDidAdd,

    // Messages

    TBMEventFlowEventMessageDidReceive,
    TBMEventFlowEventMessageDidSend,
    TBMEventFlowEventMessageDidStartPlaying,
    TBMEventFlowEventMessageDidStopPlaying,
    TBMEventFlowEventMessageDidStartRecording,
    TBMEventFlowEventMessageDidRecorded,
    TBMEventFlowEventMessageDidViewed,

    // Hints

    TBMEventFlowEventSentHintDidDismiss,
    TBMEventFlowEventFeatureUsageHintDidDismiss,

    // Unlocks dialogs

    TBMEventFlowEventFrontCameraUnlockDialogDidDismiss,
    TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss,
    TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss,
    TBMEventFlowEventEarpieceUnlockDialogDidDismiss,
    TBMEventFlowEventSpinUnlockDialogDidDismiss,
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
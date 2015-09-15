//
// Events Flow and handlers system is responsive for handle user-flow events
//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMEventFlowEvent.h"

@protocol ZZGridModuleInterface;
@protocol TBMEventsFlowModuleEventHandlerInterface;

@protocol TBMEventsFlowModuleInterface <NSObject>

/**
 * Setup grid module for hints
 */
- (void)setupGridModule:(id <ZZGridModuleInterface>)gridModule;

/**
 * States of event handlers
 */
- (void)resetSession;
- (void)resetHintsState;

/**
 * Events happens
 *
 * Parent modules send signals about application state and flow
 */
- (void)throwEvent:(TBMEventFlowEvent)anEvent;
- (BOOL)isAnyHandlerActive;
- (BOOL)isRecording;

// Event handler
- (id <TBMEventsFlowModuleEventHandlerInterface>)currentHandler;
- (void)setupCurrentHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler;
@end
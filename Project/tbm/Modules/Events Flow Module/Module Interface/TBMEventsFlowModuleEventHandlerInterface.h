/**
 *
 *  TBMEventsFlowModuleDelegate - protocol for event handlers e.g. hints, feature unlock dialogs, next feat. dialog etc.
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleInterface.h"

@protocol TBMEventsFlowModuleEventHandlerInterface <NSObject>

// Returns if handler presented
- (BOOL)isPresented;

// Resets session state
- (void)resetSessionState;

// Returns if condition is fulfilled
//- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource;
- (BOOL)conditionForEvent:(TBMEventFlowEvent)event;

// Priority for determine which handler should get the control if we have conflict
- (NSUInteger)priority;

// Presents handler
//- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule;
- (void)present;

@end
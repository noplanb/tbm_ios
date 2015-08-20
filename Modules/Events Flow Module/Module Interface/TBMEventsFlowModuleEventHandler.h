/**
 *
 *  TBMEventsFlowModuleDelegate - protocol for event handlers e.g. hints, feature unlock dialogs, next feat. dialog etc.
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleInterface.h"

@protocol TBMEventsFlowModuleDataSource;

@protocol TBMEventsFlowModuleEventHandler <NSObject>

// Returns if handler presented
- (BOOL)isPresented;

// Returns if condition is fulfilled
- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource;

// Priority for determine which handler should get the control if we have conflict
- (NSUInteger)priority;

// Presents handler
- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule;

@end
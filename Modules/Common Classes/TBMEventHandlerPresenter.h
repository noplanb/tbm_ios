/**
 *
 * Base class for hints presenters
 *
 * Created by Maksim Bazarov on 16/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"

@class TBMHintView;
@class TBMEventHandlerDataSource;
@protocol TBMDialogViewInterface;

@interface TBMEventHandlerPresenter : NSObject <TBMEventsFlowModuleEventHandler>

/**
 * Hint view should be initiated by concrete subclass
 */
@property(nonatomic, strong) id <TBMDialogViewInterface> dialogView;

/**
 * Data source only persistentStateKey should be set in subclasses
 */
@property(nonatomic, strong) TBMEventHandlerDataSource *dataSource;

/**
 * Used by subclasses for decisions
 */
@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> eventFlowModule;

/**
 * Event flow module also needs for callback events
 */
- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule;

/**
 * Handler did presented subclasses calback
 */
-(void)didPresented;

/**
 * View callback
 */
- (void)dialogDidDismiss;
@end
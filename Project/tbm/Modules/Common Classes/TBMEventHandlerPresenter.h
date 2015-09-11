/**
 *
 * Base class for hints presenters
 *
 * Created by Maksim Bazarov on 16/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "TBMDialogViewDelegate.h"

@class TBMHintView;
@protocol TBMDialogViewInterface;
@class TBMEventsFlowDataSource;

@interface TBMEventHandlerPresenter : NSObject <TBMEventsFlowModuleEventHandlerInterface, TBMDialogViewDelegate>

@property(nonatomic, weak) TBMEventsFlowDataSource *dataSource;
@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;
@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> eventFlowModule;

// State
@property(nonatomic, assign) BOOL sessionState;
@property(nonatomic) BOOL isPresented;

/**
 * Dialog view should be initiated by concrete subclass
 */
@property(nonatomic, strong) id <TBMDialogViewInterface> dialogView;


/**
 * Event flow module also needs for callback events
 */
- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule;

/**
 * Handler did presented subclasses calback
 */
- (void)didPresented;

- (void)dismissAfter:(CGFloat)delay;
@end
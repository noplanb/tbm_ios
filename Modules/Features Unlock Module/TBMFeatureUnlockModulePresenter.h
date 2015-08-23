/**
 *
 * Base class for features presenters
 *
 * Created by Maksim Bazarov on 12/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */



#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"
#import "TBMEventHandlerPresenter.h"


@interface TBMFeatureUnlockModulePresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandler>

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule;

- (void)showMeButtonDidPress;

@end
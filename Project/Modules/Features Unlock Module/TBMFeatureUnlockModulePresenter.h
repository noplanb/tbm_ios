/**
 *
 * Base class for features presenters
 *
 * Created by Maksim Bazarov on 12/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import "TBMEventsFlowModuleEventHandler.h"
#import "TBMEventHandlerPresenter.h"

@interface TBMFeatureUnlockModulePresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandler>

- (void)showMeButtonDidPress;

@end
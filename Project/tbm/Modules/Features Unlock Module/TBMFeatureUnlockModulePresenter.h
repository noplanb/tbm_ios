/**
 *
 * Base class for features presenters
 *
 * Created by Maksim Bazarov on 12/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "TBMEventHandlerPresenter.h"
#import "TBMFeatureUnlockModuleInterface.h"

@class TBMFeatureUnlockDataSource;

@interface TBMFeatureUnlockModulePresenter : TBMEventHandlerPresenter
<   TBMEventsFlowModuleEventHandlerInterface,
    TBMFeatureUnlockModuleInterface
>

- (void)showMeButtonDidSelect;

@end
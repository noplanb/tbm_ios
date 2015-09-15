//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerPresenter.h"

@interface TBMPlayHintPresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandlerInterface>

/**
 * Custom presentation logic for play and record hint
 */
- (void)addRecordHint;

@end
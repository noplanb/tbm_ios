//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMAbortRecordUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMAbortRecordUsageHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMAbortRecordUsageHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kAbortRecordUsageHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1500;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return event == TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
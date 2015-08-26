//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSpinUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMEventHandlerDataSource.h"
#import "TBMSpinUsageHintView.h"


@implementation TBMSpinUsageHintPresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMSpinUsageHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kSpinUsageUsageUsageHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1200;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return event == TBMEventFlowEventSpinUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
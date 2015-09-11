//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMHintView.h"
#import "TBMAbortRecordUsageHintView.h"


@implementation TBMAbortRecordUsageHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMAbortRecordUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1500;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event;
{
    return event == TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
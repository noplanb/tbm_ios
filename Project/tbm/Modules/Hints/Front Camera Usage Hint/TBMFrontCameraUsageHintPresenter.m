//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFrontCameraUsageHintPresenter.h"
#import "TBMHintView.h"
#import "TBMFrontCameraUsageHintView.h"


@implementation TBMFrontCameraUsageHintPresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMFrontCameraUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1600;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    return event == TBMEventFlowEventFrontCameraUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
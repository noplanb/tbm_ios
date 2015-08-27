//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFrontCameraUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMFrontCameraUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMFrontCameraUsageHintPresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMFrontCameraUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
        self.eventHandlerDataSource.persistentStateKey = @"kFrontCameraUsageUsageHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1600;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return event == TBMEventFlowEventFrontCameraUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSpinUsageHintPresenter.h"
#import "TBMHintView.h"
#import "TBMSpinUsageHintView.h"
#import "ZZStoredSettingsManager.h"

@implementation TBMSpinUsageHintPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dialogView = [TBMSpinUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1200;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    return (event == TBMEventFlowEventSpinUnlockDialogDidDismiss);
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setSpinHintWasShown:YES];
}

@end
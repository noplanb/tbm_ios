//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDeleteFriendUsageHintPresenter.h"
#import "TBMHintView.h"
#import "TBMDeleteFriendUsageHintView.h"
#import "ZZStoredSettingsManager.h"


@implementation TBMDeleteFriendUsageHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMDeleteFriendUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1400;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    return event == TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setDeleteFriendHintWasShown:YES];
}

@end
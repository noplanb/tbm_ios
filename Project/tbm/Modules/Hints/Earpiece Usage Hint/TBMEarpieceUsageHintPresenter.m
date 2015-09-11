//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEarpieceUsageHintPresenter.h"
#import "TBMHintView.h"
#import "TBMEarpieceUsageHintView.h"


@implementation TBMEarpieceUsageHintPresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMEarpieceUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1300;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    return event == TBMEventFlowEventEarpieceUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end
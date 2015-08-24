//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDeleteFriendUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMDeleteFriendUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMDeleteFriendUsageHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMDeleteFriendUsageHintView new];
        self.dataSource.persistentStateKey = @"kDeleteFriendUsageUsageHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return event == TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss;
}

@end
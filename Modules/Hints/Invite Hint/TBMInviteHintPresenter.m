//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInviteHintPresenter.h"
#import "TBMInviteHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMInviteHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMInviteHintView new];
        self.dataSource.persistentStateKey = @"kInviteHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventApplicationDidLaunch)
    {
        return NO;
    }

    if ([self.dataSource sessionState])
    {
        return NO;
    }

    return [dataSource friendsCount] == 0;
}

@end
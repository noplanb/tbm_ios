//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMWelcomeHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMWelcomeHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMWelcomeHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMWelcomeHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kWelcomeHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 800;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventFriendDidAdd)
    {
        return NO;
    }
    if ([dataSource friendsCount] <= 1)
    {
        return NO;
    }

    if ([dataSource friendsCount] > 8)
    {
        return NO;
    }

    return YES;
}

@end
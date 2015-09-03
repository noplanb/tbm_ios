//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordWelcomeHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMRecordWelcomeHintView.h"
#import "TBMPlayHintPresenter.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMRecordWelcomeHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMRecordWelcomeHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kRecordWelcomeHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1000;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{

    if (event != TBMEventFlowEventFriendDidAdd)
    {
        return NO;
    }

    return (![dataSource messageRecordedState]);

}

@end
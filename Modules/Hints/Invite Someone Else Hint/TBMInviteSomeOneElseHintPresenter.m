//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInviteSomeOneElseHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMInviteSomeoneElseHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMInviteSomeOneElseHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMInviteSomeoneElseHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kInviteSomeoneElseNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 300;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
#warning TEST PURPOSES
    return YES;

    if (event != TBMEventFlowEventMessageDidSend && event != TBMEventFlowEventSentHintDidDismiss)
    {
        return NO;
    }

    if ([self.eventHandlerDataSource sessionState])
    {
        return NO;
    }

    if ([dataSource friendsCount] != 1)
    {
        return NO;
    }

    return [dataSource messageRecordedState];

}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSentHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMSentHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMSentHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMSentHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kSentHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 600;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventMessageDidSend)
    {
        return NO;
    }

    if (![dataSource hasSentVideos:0])
    {
        return NO;
    }
    if ([self.eventHandlerDataSource persistentState])
    {
        return NO;
    }

    if ([dataSource friendsCount] > 1)
    {
        return NO;
    }

    return YES;
}

@end
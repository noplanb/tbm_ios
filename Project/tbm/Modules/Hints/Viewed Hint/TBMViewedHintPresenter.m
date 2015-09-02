//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMViewedHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMViewedHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMViewedHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMViewedHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kViewedHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 500;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventMessageDidViewed)
    {
        return NO;
    }

    if (dataSource.friendsCount != 1)
    {
        return NO;
    }

    if ([self.eventHandlerDataSource persistentState])
    {
        return NO;
    }

    return ([dataSource unviewedCountForCenterRightBox] > 0);
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    [super presentWithGridModule:gridModule];

    [self dismissAfter:3.f];
}
@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMViewedHintPresenter.h"
#import "TBMHintView.h"
#import "TBMViewedHintView.h"
#import "TBMEventsFlowDataSource.h"
#import "ZZStoredSettingsManager.h"


@implementation TBMViewedHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMViewedHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 500;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    if (event != TBMEventFlowEventMessageDidViewed)
    {
        return NO;
    }

    if (self.dataSource.friendsCount != 1)
    {
        return NO;
    }

    if ([self handlerState])
    {
        return NO;
    }

    return ([self.dataSource unviewedCountForCenterRightBox] > 0);
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    [super present];

    [self dismissAfter:3.f];
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setViewedHintWasShown:YES];
}

- (BOOL)handlerState
{
    return [[ZZStoredSettingsManager shared] viewedHintWasShown];
}

@end
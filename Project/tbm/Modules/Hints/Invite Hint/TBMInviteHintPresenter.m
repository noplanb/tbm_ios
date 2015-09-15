//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInviteHintPresenter.h"
#import "TBMInviteHintView.h"
#import "TBMEventsFlowDataSource.h"
#import "ZZStoredSettingsManager.h"


@implementation TBMInviteHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMInviteHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1700;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    if (event != TBMEventFlowEventApplicationDidLaunch)
    {
        return NO;
    }


    return ([self.dataSource friendsCount] == 0);
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setInviteHintWasShown:YES];
}
@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMWelcomeHintPresenter.h"
#import "TBMHintView.h"
#import "TBMWelcomeHintView.h"
#import "TBMEventsFlowDataSource.h"
#import "ZZStoredSettingsManager.h"


@implementation TBMWelcomeHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMWelcomeHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 800;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    if (event != TBMEventFlowEventFriendDidAdd)
    {
        return NO;
    }
    NSUInteger friendsCount = [self.dataSource friendsCount];
    if (friendsCount <= 1)
    {
        return NO;
    }

    if (friendsCount > 8)
    {
        return NO;
    }

    return YES;
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setWelcomeHintWasShown:YES];
}

@end
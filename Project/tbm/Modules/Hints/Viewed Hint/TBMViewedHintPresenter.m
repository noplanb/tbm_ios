//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMViewedHintPresenter.h"
#import "TBMHintView.h"
#import "TBMViewedHintView.h"


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

    if ([self.dataSource persistentStateForHandler:self])
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
@end
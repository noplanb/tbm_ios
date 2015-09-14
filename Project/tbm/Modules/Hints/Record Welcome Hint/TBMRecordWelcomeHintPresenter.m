//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordWelcomeHintPresenter.h"
#import "TBMHintView.h"
#import "TBMRecordWelcomeHintView.h"
#import "TBMPlayHintPresenter.h"


@implementation TBMRecordWelcomeHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMRecordWelcomeHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1000;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{

    if (event != TBMEventFlowEventFriendDidAdd)
    {
        return NO;
    }

    return (![self.dataSource messageRecordedState]);

}

@end
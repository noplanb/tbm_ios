//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInviteSomeOneElseHintPresenter.h"
#import "TBMHintView.h"
#import "TBMInviteSomeoneElseHintView.h"

@implementation TBMInviteSomeOneElseHintPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dialogView = [TBMInviteSomeoneElseHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 300;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    if (event != TBMEventFlowEventMessageDidSend
            && event != TBMEventFlowEventSentHintDidDismiss)
    {
        return NO;
    }

    if ([self sessionState])
    {
        return NO;
    }

    return (([self.dataSource friendsCount] == 1) && ([self.dataSource unviewedCount] == 0));

}

@end
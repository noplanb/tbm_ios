//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMWelcomeHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMWelcomeHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMWelcomeHintPresenter

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMWelcomeHintView new];
    self.dataSource.persistentStateKey = @"*const kWelcomeHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventFriendDidAdd) {
        return NO;
    }
    if ([dataSource friendsCount] <= 1) {
        return NO;
    }

    if ([dataSource friendsCount] > 8) {
        return NO;
    }

    if ([self.dataSource persistentState]) {
        return NO;
    }

    return YES;
}


- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [super presentWithGridModule:gridModule];
    }
}

@end
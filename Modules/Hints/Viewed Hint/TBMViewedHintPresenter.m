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

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMViewedHintView new];
    self.dataSource.persistentStateKey = @"kViewedHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventMessageDidViewed) {
        return NO;
    }

    if (dataSource.friendsCount != 1) {
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
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

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMSentHintView new];
    self.dataSource.persistentStateKey = @"kSentHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventMessageDidSend) {
        return NO;
    }

    if (![dataSource hasSentVideos:0]) {
        return NO;
    }
    if ([self.dataSource persistentState]) {
        return NO;
    }

    if ([dataSource friendsCount] > 1) {
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
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSource.h"
#import "TBMHintView.h"
#import "TBMAbortRecordUsageHintView.h"


@implementation TBMAbortRecordUsageHintPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    [self setHintView:[TBMAbortRecordUsageHintView new]];
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {
    if (event != TBMEventFlowEventMessageDidSend) {
        return NO;
    }

    if (![dataSource hasSentVideos:0]) {
        return NO;
    }
    if ([dataSource sentHintState]) {
        return NO;
    }

    if ([dataSource friendsCount] > 1) {
        return NO;
    }

    return YES;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [dataSource setAbortRecordUsageHintState:YES];
        [dataSource setAbortRecordUsageHintSessionState:YES];

        _isPresented = YES;
        [self.hintView showHintInGrid:gridModule];
    } else {
        _isPresented = NO;
    }
}

- (NSUInteger)priority {
    return 1;
}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMAbortRecordUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMAbortRecordUsageHintPresenter

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMAbortRecordUsageHintView new];
    self.dataSource.persistentStateKey = @"kAbortRecordUsageHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 9;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss) {
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
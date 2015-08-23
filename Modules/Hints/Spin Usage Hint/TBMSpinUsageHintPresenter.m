//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSpinUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMEventHandlerDataSource.h"
#import "TBMSpinUsageHintView.h"


@implementation TBMSpinUsageHintPresenter
- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMSpinUsageHintView new];
    self.dataSource.persistentStateKey = @"kSpinUsageUsageUsageHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
        if (event != TBMEventFlowEventSpinUnlockDialogDidDismiss) {
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
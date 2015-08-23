//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFrontCameraUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMFrontCameraUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMFrontCameraUsageHintPresenter
- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMFrontCameraUsageHintView new];
    self.dataSource.persistentStateKey = @"kFrontCameraUsageUsageHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventFrontCameraUnlockDialogDidDismiss) {
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
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMPlayHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMPlayHintView.h"
#import "TBMRecordHintPresenter.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMPlayHintPresenter

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMPlayHintView new];
    self.dataSource.persistentStateKey = @"kPlayHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {

    if (event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventMessageDidRecorded
            && event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    if (self.eventFlowModule.isRecording) {
        return NO;
    }

    if ([self.dataSource sessionState]) {
        return NO;
    }

    if ([dataSource unviewedCount] <= 0) {
        return NO;
    }

    if ([dataSource messagePlayedState]) {
        return NO;
    }

    if ([dataSource friendsCount] != 1) {
        return NO;
    }


    return YES;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [super presentWithGridModule:gridModule];
    } else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addPlayHint)]) {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addPlayHint)];
        [self didPresented];
    }
}


#pragma mark Add record hint implementation

- (void)addRecordHint {
    TBMPlayHintView *view = self.dialogView;
    [view addRecordTip];
}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMRecordHintView.h"
#import "TBMPlayHintPresenter.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMRecordHintPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMRecordHintView new];
    self.dataSource.persistentStateKey = @"kRecordHintNSUDkey";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {

    if (event != TBMEventFlowEventMessageDidStopPlaying
            && event != TBMEventFlowEventFriendDidAdd
            && event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    if ([dataSource messageRecordedState]) {
        return NO;
    }

    if ([self.dataSource sessionState]) {
        return NO;
    }

    if ([dataSource friendsCount] != 1) {
        return NO;
    }

    return YES;
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [super presentWithGridModule:gridModule];
    } else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addRecordHint)]) {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addRecordHint)];
        [self didPresented];
    }
}

#pragma mark Add play hint implementation

- (void)addPlayHint {
    TBMRecordHintView *view = self.dialogView;
    [view addPlayTip];
}
@end
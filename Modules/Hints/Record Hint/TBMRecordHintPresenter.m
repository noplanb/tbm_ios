//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordHintPresenter.h"
#import "TBMEventsFlowModuleDataSource.h"
#import "TBMHintView.h"
#import "TBMRecordHintView.h"
#import "TBMPlayHintPresenter.h"


@implementation TBMRecordHintPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    [self setHintView:[TBMRecordHintView new]];
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {

    if (event != TBMEventFlowEventMessageDidStopPlaying
            && event != TBMEventFlowEventFriendDidAdd
            && event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    if ([dataSource messageRecordedState]) {
        return NO;
    }

    if ([dataSource recordHintSessionState]) {
        return NO;
    }

    if ([dataSource friendsCount] != 1) {
        return NO;
    }

    return YES;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [self setRecordHintStates:dataSource];
        _isPresented = YES;
        [self.hintView showHintInGrid:gridModule];
    } else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addRecordHint)]) {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addRecordHint)];
        [self setRecordHintStates:dataSource];
        _isPresented = YES;
    } else {
        _isPresented = NO;
    }
}

- (void)setRecordHintStates:(id <TBMEventsFlowModuleDataSource>)dataSource {
    [dataSource setRecordHintState:YES];
    [dataSource setRecordHintSessionState:YES];
}

- (NSUInteger)priority {
    return 1;
}

#pragma mark Add play hint implementation

- (void)addPlayHint {
    TBMRecordHintView *view = self.hintView;
    [view addPlayTip];
}
@end
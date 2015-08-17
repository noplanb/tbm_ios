//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMPlayHintPresenter.h"
#import "TBMEventsFlowModuleDataSource.h"
#import "TBMHintView.h"
#import "TBMPlayHintView.h"
#import "TBMRecordHintPresenter.h"


@implementation TBMPlayHintPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    [self setHintView:[TBMPlayHintView new]];
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {

    if (event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventMessageDidRecorded
            && event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    if (self.eventFlowModule.isRecording) {
        return NO;
    }

    if ([dataSource playHintSessionState]) {
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

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [self setPlayHintStates:dataSource];
        _isPresented = YES;
        [self.hintView showHintInGrid:gridModule];
    } else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addPlayHint)]) {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addPlayHint)];
        [self setPlayHintStates:dataSource];
        _isPresented = YES;
    } else {
        _isPresented = NO;
    }
}

- (void)setPlayHintStates:(id <TBMEventsFlowModuleDataSource>)dataSource {
    [dataSource setPlayHintState:YES];
    [dataSource setPlayHintSessionState:YES];
}

- (NSUInteger)priority {
    return 1;
}

#pragma mark Add record hint implementation

- (void)addRecordHint {
    TBMPlayHintView *view = self.hintView;
    [view addRecordTip];
}

@end
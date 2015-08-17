//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMViewedHintPresenter.h"
#import "TBMEventsFlowModuleDataSource.h"
#import "TBMHintView.h"
#import "TBMViewedHintView.h"


@implementation TBMViewedHintPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    [self setHintView:[TBMViewedHintView new]];
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {
    if (event != TBMEventFlowEventMessageDidViewed) {
        return NO;
    }

    if (dataSource.friendsCount != 1) {
        return NO;
    }

    if ([dataSource viewedHintState]) {
        return NO;
    }

    return YES;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [dataSource setViewedHintState:YES];
        [dataSource setViewedHintSessionState:YES];

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
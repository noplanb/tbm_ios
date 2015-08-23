//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFeatureUnlockModulePresenter.h"
#import "TBMEventHandlerDataSource.h"
#import "TBMFeatureUnlockDialogView.h"


@interface TBMFeatureUnlockModulePresenter ()
@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> eventFlowModule;
@end

@implementation TBMFeatureUnlockModulePresenter
- (instancetype)init {
    self = [super init];
    self.dialogView = [TBMFeatureUnlockDialogView new];
    self.dataSource.persistentStateKey = @"";
    return self;
}

- (NSUInteger)priority {
    return 1;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
//    if (event != TBMEventFlowEventMessageDidSend) {
//        return NO;
//    }
    // LOGIC GOES HERE
    return YES;
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule {
    if (![self.eventFlowModule isAnyHandlerActive]) {
        [super presentWithGridModule:gridModule];
    }
}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule {
    self.eventFlowModule = eventFlowModule;
}

- (void)showMeButtonDidPress {
    //
}


@end
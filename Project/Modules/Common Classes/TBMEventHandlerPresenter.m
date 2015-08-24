//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerPresenter.h"
#import "TBMHintView.h"
#import "TBMEventHandlerDataSource.h"
#import "OBLoggerCore.h"

@implementation TBMEventHandlerPresenter


- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dataSource = [TBMEventHandlerDataSource new];
    }
    return self;
}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule
{
    self.eventFlowModule = eventFlowModule;
}

- (void)resetSessionState
{
    [self.dataSource setSessionState:NO];
}

- (void)didPresented
{
    self.isPresented = YES;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return NO;
}

- (NSUInteger)priority
{
    return 0;
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    if (![self.eventFlowModule isAnyHandlerActive])
    {
        self.isPresented = YES;
        [self saveHandlerState];
        [self.dialogView showInGrid:gridModule];
    }
}

- (void)saveHandlerState
{
    [self.dataSource setPersistentState:YES];
    [self.dataSource setSessionState:YES];
}

- (void)dialogDidDismiss
{
    OB_INFO(@"%@ did dismiss", [self.dialogView class]);
}
@end
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
        self.eventHandlerDataSource = [TBMEventHandlerDataSource new];
    }
    return self;
}

- (void)setDialogView:(id <TBMDialogViewInterface>)dialogView
{
    _dialogView = dialogView;
    [_dialogView setupDialogViewDelegate:self];
}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule
{
    self.eventFlowModule = eventFlowModule;
}

- (void)resetSessionState
{
    [self.eventHandlerDataSource setSessionState:NO];
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
    [self.eventHandlerDataSource setPersistentState:YES];
    [self.eventHandlerDataSource setSessionState:YES];
}

- (void)dialogDidDismiss
{
    self.isPresented = NO;
    OB_INFO(@"%@ did dismiss", [self.dialogView class]);
}
@end
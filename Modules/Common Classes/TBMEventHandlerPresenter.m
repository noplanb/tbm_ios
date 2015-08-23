//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerPresenter.h"
#import "TBMHintView.h"
#import "TBMEventHandlerDataSource.h"
#import "OBLoggerCore.h"
#import "TBMDialogViewInterface.h"

@implementation TBMEventHandlerPresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isPresented = NO;
        self.dataSource = [TBMEventHandlerDataSource new];
    }
    return self;
}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule {
    self.eventFlowModule = eventFlowModule;
}

- (void)resetSessionState {
    [self.dataSource setSessionState:NO];
}

- (BOOL)isPresented {
    return _isPresented;
}

- (void)didPresented {
    _isPresented = YES;
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule {
    _isPresented = YES;
    [self saveHandlerState];
    [self.dialogView showInGrid:gridModule];
}

- (void)saveHandlerState {
    [self.dataSource setPersistentState:YES];
    [self.dataSource setSessionState:YES];
}

- (void)dialogDidDismiss {
    OB_INFO(@"@% did dismiss", [self.dialogView class]);
}
@end
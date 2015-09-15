//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerPresenter.h"
#import "TBMHintView.h"
#import "OBLoggerCore.h"
#import "TBMEventsFlowDataSource.h"
#import "ZZStoredSettingsManager.h"

@implementation TBMEventHandlerPresenter

- (void)setDialogView:(id <TBMDialogViewInterface>)dialogView
{
    _dialogView = dialogView;
    [_dialogView setupDialogViewDelegate:self];
}

- (void)resetSessionState
{
    [self setSessionState:NO];
}

- (void)didPresented
{
    self.isPresented = YES;
    [self saveHandlerState];
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    return NO;
}

- (NSUInteger)priority
{
    return 0;
}

- (void)present
{
    if (![self.eventFlowModule isAnyHandlerActive])
    {
        [self didPresented];
        [self.dialogView showInGrid:self.gridModule];
    }
}

- (void)saveHandlerState
{
    [self setSessionState:YES];
    //[[ZZStoredSettingsManager shared] <%CONCRETE_METHOD%>:YES];
    //needs to override in
}

- (void)dialogDidDismiss
{
    [self.eventFlowModule setupCurrentHandler:self]; // Need for hints which can be added to another hint

    self.isPresented = NO;
    OB_INFO(@"%@ did dismiss", [self.dialogView class]);
}


- (void)dismissAfter:(CGFloat)delay
{
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC));
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^
    {
        [self.dialogView dismiss];
    });

}
@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSentHintPresenter.h"
#import "TBMHintView.h"
#import "TBMSentHintView.h"
#import "TBMEventsFlowDataSource.h"
#import "ZZStoredSettingsManager.h"


@implementation TBMSentHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMSentHintView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (NSUInteger)priority
{
    return 600;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    if (event != TBMEventFlowEventMessageDidSend)
    {
        return NO;
    }

    if (![self.dataSource hasSentVideos:0])
    {
        return NO;
    }

    return (([self.dataSource friendsCount] == 1) && (![self handlerState]));

}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    [super present];

    [self dismissAfter:3.f];
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];
    [self.eventFlowModule throwEvent:TBMEventFlowEventSentHintDidDismiss];
}

//TODO: Needs datasource here
- (void)saveHandlerState
{
    [super saveHandlerState];

    [[ZZStoredSettingsManager shared] setSentHintWasShown:YES];
}

- (BOOL)handlerState
{
    return [[ZZStoredSettingsManager shared] sentHintWasShown];
}

@end
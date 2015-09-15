//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMNextFeatureDialogPresenter.h"
#import "TBMNextFeatureDialogView.h"
#import "TBMHomeModuleInterface.h"
#import "TBMFeatureUnlockModuleInterface.h"
#import "ZZGridModuleInterface.h"

@implementation TBMNextFeatureDialogPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMNextFeatureDialogView new];
        [self.dialogView setupDialogViewDelegate:self];
    }
    return self;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{

    if (
            event != TBMEventFlowEventFeatureUsageHintDidDismiss
                    && event != TBMEventFlowEventMessageDidSend
                    && event != TBMEventFlowEventMessageDidStopPlaying
            )
    {
        return NO;
    }

    id <TBMEventsFlowModuleEventHandlerInterface> someOneElseHintModule = self.inviteSomeOneElseHintModule;

    if (event == TBMEventFlowEventMessageDidSend && [someOneElseHintModule conditionForEvent:TBMEventFlowEventMessageDidSend])
    {
        return NO;
    }

    if (event == TBMEventFlowEventMessageDidStopPlaying && [someOneElseHintModule conditionForEvent:TBMEventFlowEventMessageDidStopPlaying])
    {
        return NO;
    }

    if (![self.featureUnlockModule hasFeaturesForUnlock])
    {
        return NO;
    }

    return YES;
}

- (NSUInteger)priority
{
    return 200;
}

#pragma mark - View Callbacks

- (void)dialogDidTap
{
    [self.gridModule presentMenu];
}

@end
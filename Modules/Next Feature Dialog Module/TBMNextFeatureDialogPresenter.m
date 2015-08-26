//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMNextFeatureDialogPresenter.h"
#import "TBMNextFeatureDialogView.h"
#import "TBMHomeModuleInterface.h"
#import "TBMEventHandlerDataSource.h"
#import "TBMFeatureUnlockModuleInterface.h"

@interface TBMNextFeatureDialogPresenter ()

@property(nonatomic, strong) id <TBMHomeModuleInterface> homeModule;
@property(nonatomic, strong) id <TBMFeatureUnlockModuleInterface> featureUnlockModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> inviteSomeOneElseHintModule;

@end

@implementation TBMNextFeatureDialogPresenter

- (instancetype)init
{
    self = [super init]; //todo:

    if (self)
    {
        self.dialogView = [TBMNextFeatureDialogView new];
        [self.dialogView setupDialogViewDelegate:self];
        self.eventHandlerDataSource.persistentStateKey = @""; // it means don't store
    }
    return self;
}

- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule
{
    self.homeModule = homeModule;
}

- (void)setupInviteSomeOneElseHintModule:(id <TBMEventsFlowModuleEventHandler>)inviteSomeOneElseHintModule
{
    self.inviteSomeOneElseHintModule = inviteSomeOneElseHintModule;
}

- (void)setupFeatureUnlockModule:(id <TBMFeatureUnlockModuleInterface>)featureUnlockModule
{
    self.featureUnlockModule = featureUnlockModule;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventMessageDidStopPlaying
            && event != TBMEventFlowEventMessageDidSend
            && event != TBMEventFlowEventFeatureUsageHintDidDismiss
            )
    {
        return NO;
    }

    if (event == TBMEventFlowEventMessageDidSend
            && [self.inviteSomeOneElseHintModule conditionForEvent:TBMEventFlowEventMessageDidSend dataSource:dataSource])
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
    [self.homeModule showBench];
}


@end